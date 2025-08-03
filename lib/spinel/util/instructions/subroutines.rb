# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to all possible
      # CALL and RET instructions
      #
      class Subroutines
        attr_reader :mnemonic, :bytes, :cycles

        # @param operation [Symbol] Which type of Jump
        # @param flag [Symbol] Which flag to check for the jump (Z or C)
        # @param value_check [Integer] Value to check in the flag (1 or 0)
        #
        def initialize(operation, flag = :none, value_check = nil, fixed_address: nil)
          @operation = operation
          @flag = flag
          @value_check = value_check
          @fixed_address = fixed_address

          @mnemonic = metadata[:mnemonic]
          @bytes = metadata[:bytes]
          @cycles = metadata[:cycles]
        end

        def execute(cpu)
          case @operation
          when :call_imm16 then call_imm16(cpu)
          when :ret_flag   then ret_flag(cpu)
          when :ret        then ret(cpu)
          when :reti       then reti(cpu)
          when :rst        then rst(cpu)
          else
            raise ArgumentError, "Invalid Subroutine operation: #{@operation}."
          end
        end

        private

        def call_mnemonic
          return 'CALL imm16' if @flag == :none

          case @flag
          when :z_flag
            @value_check == 1 ? 'CALL Z, imm16' : 'CALL NZ, imm16'
          when :c_flag
            @value_check == 1 ? 'CALL C, imm16' : 'CALL NC, imm16'
          when :none then 'CALL imm16'
          else
            raise ArgumentError, "Invalid flag provided: #{@flag}"
          end
        end

        def ret_mnemonic
          case @flag
          when :z_flag
            @value_check == 1 ? 'RET Z' : 'RET NZ'
          when :c_flag
            @value_check == 1 ? 'RET C' : 'RET NC'
          else
            raise ArgumentError, "Invalid flag provided: #{@flag}"
          end
        end

        def call_cycles
          @flag == :none ? 24 : 12
        end

        def metadata
          case @operation
          when :call_imm16
            { mnemonic: call_mnemonic, bytes: 3, cycles: call_cycles }
          when :ret_flag
            { mnemonic: ret_mnemonic, bytes: 1, cycles: 8 }
          when :ret
            { mnemonic: 'RET', bytes: 1, cycles: 16 }
          when :reti
            { mnemonic: 'RETI', bytes: 1, cycles: 16 }
          when :rst
            { mnemonic: "RST $#{format('%02X', @fixed_address)}", bytes: 1, cycles: 16 }
          end
        end

        # Fetches the address of the next instruction
        # Stores that into the Stack to return later
        # Since the CALL is 3 bytes long it takes PC + 3
        #
        # M-cycles 1 => Fetches opcode
        # M-cycles 2 => Fetches low byte
        # M-cycles 3 => Fetches high byte, returns early if condition is not met
        # M-cycles 4 => Calculates the jump address and return address
        # M-cycles 5 => Pushes the MSB of the return address into the stack
        # M-cycles 6 => Pushes the LSB of the return address into the stack, sets jump to PC
        #
        def call_imm16(cpu)
          lsb = cpu.fetch_next_byte
          msb = cpu.fetch_next_byte

          return if @flag != :none && cpu.registers.send(@flag) != @value_check

          jump_address = cpu.calculate_address(lsb, msb)

          return_address = cpu.registers.pc
          return_address_lsb = return_address & 0xFF
          return_address_msb = (return_address >> 8) & 0xFF

          cpu.registers.sp -= 1
          cpu.bus_write(cpu.registers.sp, return_address_msb)

          cpu.registers.sp -= 1
          cpu.bus_write(cpu.registers.sp, return_address_lsb)

          cpu.registers.pc = jump_address
        end

        # Returns from a subroutine execution conditionally
        #
        # M-cycles 1 => Fetches opcode
        # M-cycles 2 => Checks condition, returns early if condition is not met
        # M-cycles 3 => Pops the LSB of the address from the stack
        # M-cycles 4 => Pops the MSB of the address from the stack
        # M-cycles 5 => Calculates address and jumps to it
        #
        def ret_flag(cpu)
          cpu.internal_delay(cycles: 1)
          return if @flag != :none && cpu.registers.send(@flag) != @value_check

          lsb = cpu.bus_read(cpu.registers.sp)
          cpu.registers.sp += 1

          msb = cpu.bus_read(cpu.registers.sp)
          cpu.registers.sp += 1

          jump_address = cpu.calculate_address(lsb, msb)
          cpu.registers.pc = jump_address
        end

        # Returns from a subroutine
        #
        # M-cycles 1 => Fetches opcode
        # M-cycles 2 => Pops the LSB of the address from the stack
        # M-cycles 3 => Pops the MSB of the address from the stack
        # M-cycles 4 => Calculates address and jumps to it
        #
        def ret(cpu)
          lsb = cpu.bus_read(cpu.registers.sp)
          cpu.registers.sp += 1

          msb = cpu.bus_read(cpu.registers.sp)
          cpu.registers.sp += 1

          jump_address = cpu.calculate_address(lsb, msb)
          cpu.registers.pc = jump_address
        end

        # Performs an unconditional RET and immediately enables interrupts (IME = 1)
        #
        # M-cycles 1 => Fetches opcode
        # M-cycles 2 => Pops the LSB of the address from the stack
        # M-cycles 3 => Pops the MSB of the address from the stack
        # M-cycles 4 => Calculates address and jumps to it
        #
        def reti(cpu)
          lsb = cpu.bus_read(cpu.registers.sp)
          cpu.registers.sp += 1

          msb = cpu.bus_read(cpu.registers.sp)
          cpu.registers.sp += 1

          jump_address = cpu.calculate_address(lsb, msb)
          cpu.registers.pc = jump_address
          cpu.ime_flag = true
        end

        # Performs an unconditional RET and immediately enables interrupts (IME = 1)
        #
        # M-cycles 1 => Fetches opcode
        # M-cycles 2 => Internal delay for processing ???
        # M-cycles 3 => Pushes MSB of return address into the stack
        # M-cycles 4 => Pushes LSB of return address into the stack and jumps to fixed address
        #
        def rst(cpu)
          cpu.internal_delay(cycles: 1)

          return_address = cpu.registers.pc
          return_address_lsb = return_address & 0xFF
          return_address_msb = (return_address >> 8) & 0xFF

          cpu.registers.sp -= 1
          cpu.bus_write(cpu.registers.sp, return_address_msb)

          cpu.registers.sp -= 1
          cpu.bus_write(cpu.registers.sp, return_address_lsb)

          cpu.registers.pc = @fixed_address
        end
      end
    end
  end
end
