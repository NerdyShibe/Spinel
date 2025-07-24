# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to all possible
        # CALL and RET instructions
        #
        class Subroutines < Base
          # @param operation [Symbol] Which type of Jump
          # @param flag [Symbol] Which flag to check for the jump (Z or C)
          # @param value_check [Integer] Value to check in the flag (1 or 0)
          #
          def initialize(operation, flag = :none, value_check = nil, fixed_address: nil)
            @operation = operation
            @flag = flag
            @value_check = value_check
            @fixed_address = fixed_address

            super(
              mnemonic: metadata[:mnemonic],
              bytes: metadata[:bytes],
              cycles: metadata[:cycles]
            )
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
          def call_imm16(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.pc)
            when 8 then @lsb = cpu.receive_data
            when 9 then cpu.request_read(cpu.registers.pc) # rubocop:disable Lint/DuplicateBranch
            when 12
              @msb = cpu.receive_data
              return if @flag == :none

              self.cycles = 24 if cpu.registers.send(@flag) == @value_check
            when 13
              @return_address = cpu.registers.pc + bytes
              cpu.registers.sp -= 1
              cpu.request_write(cpu.registers.sp)
            when 16 then cpu.confirm_write(@return_address >> 8)
            when 17
              cpu.registers.sp -= 1
              cpu.request_write(cpu.registers.sp)
            when 20 then cpu.confirm_write(@return_address & 0xFF)
            when 24
              jump_address = (@msb << 8) | @lsb
              puts "Jumping to $#{format('%04X', jump_address)}..."
              cpu.registers.pc = jump_address
            else wait
            end
          end

          def ret_flag(cpu)
            case cpu.ticks
            when 8
              self.cycles = 20 if cpu.registers.send(@flag) == @value_check
            when 9 then cpu.request_read(cpu.registers.sp)
            when 12
              @lsb = cpu.receive_data
              cpu.registers.sp += 1
            when 13 then cpu.request_read(cpu.registers.sp) # rubocop:disable Lint/DuplicateBranch
            when 16
              @msb = cpu.receive_data
              cpu.registers.sp += 1
            when 20
              address = (@msb << 8) | @lsb
              puts "Jumping to $#{format('%04X', address)}..."
              cpu.registers.pc = address
            else wait
            end
          end

          def ret(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.sp)
            when 8
              @lsb = cpu.receive_data
              cpu.registers.sp += 1
            when 9 then cpu.request_read(cpu.registers.sp) # rubocop:disable Lint/DuplicateBranch
            when 12
              @msb = cpu.receive_data
              cpu.registers.sp += 1
            when 16
              address = (@msb << 8) | @lsb
              puts "Jumping to $#{format('%04X', address)}..."
              cpu.registers.pc = address
            else wait
            end
          end

          def reti(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.sp)
            when 8
              @lsb = cpu.receive_data
              cpu.registers.sp += 1
            when 9 then cpu.request_read(cpu.registers.sp)
            when 12
              @msb = cpu.receive_data
              cpu.registers.sp += 1
            when 16
              address = (@msb << 8) | @lsb
              puts "Jumping to $#{format('%04X', address)}..."
              cpu.registers.pc = address
              cpu.ime_flag = true
            else wait
            end
          end

          def rst(cpu)
            case cpu.ticks
            when 5
              @return_address = cpu.registers.pc + bytes
              cpu.registers.sp -= 1
              cpu.request_write(cpu.registers.sp)
            when 8 then cpu.confirm_write(@return_address >> 8)
            when 9
              cpu.registers.sp -= 1
              cpu.request_write(cpu.registers.sp)
            when 12 then cpu.confirm_write(@return_address & 0xFF)
            when 16
              puts "Jumping to $#{format('%04X', @fixed_address)}..."
              cpu.registers.pc = @fixed_address
            else wait
            end
          end
        end
      end
    end
  end
end
