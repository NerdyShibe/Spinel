# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to all possible
        # Jump and Jump Relative instructions
        #
        class Jump
          # @param operation [Symbol] Which type of Jump
          # @param flag [Symbol] Which flag to check for the jump (Z or C)
          # @param value_check [Integer] Value to check in the flag (1 or 0)
          #
          def initialize(operation, flag = :none, value_check = nil)
            @operation = operation
            @flag = flag
            @value_check = value_check

            super(
              mnemonic: metadata[:mnemonic],
              bytes: metadata[:bytes],
              cycles: metadata[:cycles]
            )
          end

          def execute(cpu)
            case @operation
            when :jr_sig8  then jr_sig8(cpu)
            when :jp_imm16 then jp_imm16(cpu)
            when :jp_hl    then jp_hl(cpu)
            else
              raise ArgumentError, "Invalid Jump operation: #{@operation}."
            end
          end

          private

          def current_mnemonic(value)
            case @flag
            when :z_flag
              @value_check == 1 ? "Z, #{value}" : "NZ, #{value}"
            when :c_flag
              @value_check == 1 ? "C, #{value}" : "NC, #{value}"
            when :none then value
            else
              raise ArgumentError, "Invalid flag provided: #{@flag}"
            end
          end

          def current_cycles
            case @operation
            when :jr_sig8
              @flag == :none ? 12 : 8
            when :jp_imm16
              @flag == :none ? 16 : 12
            else
              raise ArgumentError, "Invalid Jump operation: #{@operation}."
            end
          end

          def metadata
            case @operation
            when :jr_sig8
              { mnemonic: "JR #{current_mnemonic('sig8')}", bytes: 2, cycles: current_cycles }
            when :jp_imm16
              { mnemonic: "JP #{current_mnemonic('imm16')}", bytes: 3, cycles: current_cycles }
            when :jp_hl
              { mnemonic: 'JP HL', bytes: 1, cycles: 4 }
            end
          end

          # Fetches the next immediate byte from memory
          # Checks if a given flag is set or not (Z or C)
          # Converts the byte into a signed integer (-128 to +127)
          # Jumps relative to the offset given by the signed value
          #
          def jr_sig8(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.pc)
            when 8
              @unsigned_byte = cpu.receive_data
              return if @flag == :none

              self.cycles = 12 if cpu.registers.send(@flag) == @value_check
            when 12
              signed_byte = @unsigned_byte >= 128 ? @unsigned_byte - 256 : @unsigned_byte
              puts "Jumping relative to #{signed_byte}..."
              cpu.registers.pc += signed_byte
            else wait
            end
          end

          # M-cycle 1 (04 ticks) => Fetches the opcode
          # M-cycle 2 (08 ticks) => Fetches the first immediate byte (least significant)
          # M-cycle 3 (12 ticks) => Fetches the second immediate byte (most significant) and checks jump flag
          # M-cycle 4 (16 ticks) => If the condition is true or is unconditional (no flag), performs the jump
          #
          def jp_imm16(cpu)
            lsb = cpu.bus_read(cpu.registers.pc)
            msb = cpu.bus_read(cpu.registers.pc)

            return if @flag != :none && cpu.registers.send(@flag) != @value_check

            jump_address = (msb << 8) | lsb
            cpu.update_pc(jump_address)
          end

          # Jumps to the value of the HL register pair
          #
          def jp_hl(cpu)
            case cpu.ticks
            when 4
              puts "Jumping to $#{format('%04X', cpu.registers.hl)}..."
              cpu.registers.pc = cpu.registers.hl
            else wait
            end
          end
        end
      end
    end
  end
end
