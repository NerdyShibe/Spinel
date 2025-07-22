# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to all possible ADD instructions
        #
        class Add < Base
          VALID_OPERATIONS = %i[
            add_a_reg8
            add_a_mem_hl
            add_a_imm8
            add_hl_reg16
            add_sp_sig8
          ].freeze

          # @param operation [Symbol] Which type of Addition
          # @param operand [Symbol]
          #
          def initialize(operation, operand = nil)
            validate(operation)

            @operation = operation
            @operand = operand

            super(
              mnemonic: metadata[:mnemonic],
              bytes: metadata[:bytes],
              cycles: metadata[:cycles]
            )
          end

          def execute(cpu)
            case @operation
            when :add_a_reg8   then add_a_reg8(cpu)
            when :add_a_mem_hl then add_a_mem_hl(cpu)
            when :add_a_imm8   then add_a_imm8(cpu)
            when :add_hl_reg16 then add_hl_reg16(cpu)
            when :add_sp_sig8  then add_sp_sig8(cpu)
            end
          end

          private

          # TODO: Validate operand also? Use respond_to? maybe
          def validate(operation)
            return if VALID_OPERATIONS.include?(operation)

            raise ArgumentError, "Invalid ADD operation: #{operation}. " \
                                 "Must be one of #{VALID_OPERATIONS.inspect}"
          end

          def metadata
            case @operation
            when :add_a_reg8
              { mnemonic: "ADD A, #{@operand.to_s.upcase}", bytes: 1, cycles: 4 }
            when :add_a_mem_hl
              { mnemonic: 'ADD A, [HL]', bytes: 1, cycles: 8 }
            when :add_a_imm8
              { mnemonic: 'ADD A, imm8', bytes: 2, cycles: 8 }
            when :add_hl_reg16
              { mnemonic: "ADD HL, #{@operand.to_s.upcase}", bytes: 1, cycles: 8 }
            when :add_sp_sig8
              { mnemonic: 'ADD SP, sig8', bytes: 2, cycles: 16 }
            end
          end

          def add_a(cpu, value)
            accumulator = cpu.registers.a
            puts "Adding #{format('%02X', value)} to A: #{format('%02X', accumulator)}"
            result = (accumulator + value) & 0xFF

            cpu.registers.z_flag = result.zero?
            cpu.registers.n_flag = false
            cpu.registers.h_flag = ((accumulator & 0x0F) + (value & 0x0F)) > 0x0F
            cpu.registers.c_flag = (accumulator + value) > 0xFF

            cpu.registers.a = result
          end

          def add_a_reg8(cpu)
            case cpu.ticks
            when 4
              reg8_value = cpu.registers.send(@operand)
              add_a(cpu, reg8_value)
            else wait
            end
          end

          def add_a_mem_hl(cpu)
            case cpu.ticks
            when 5
              address = cpu.registers.hl
              cpu.request_read(address)
            when 8
              value_at_mem_hl = cpu.receive_data
              add_a(cpu, value_at_mem_hl)
            else wait
            end
          end

          def add_a_imm8(cpu)
            case cpu.ticks
            when 5 then cpu.request_read
            when 8
              immediate_byte = cpu.receive_data
              add_a(cpu, immediate_byte)
            else wait
            end
          end

          def add_hl_reg16(cpu)
            case cpu.ticks
            when 8
              value = cpu.registers.send(@operand)
              hl_reg = cpu.registers.hl
              puts "Adding #{format('%04X', value)} to HL: #{format('%04X', hl_reg)}"
              result = (hl_reg + value) & 0xFFFF

              cpu.registers.n_flag = false
              cpu.registers.h_flag = ((hl_reg & 0x0FFF) + (value & 0x0FFF)) > 0x0FFF
              cpu.registers.c_flag = (hl_reg + value) > 0xFFFF

              cpu.registers.hl = result
            else wait
            end
          end

          # Adds a signed 8-bit value into the Stack Pointer (SP)
          #
          def add_sp_sig8(cpu)
            case cpu.ticks
            when 5 then cpu.request_read
            when 8 then @unsigned_byte = cpu.receive_data
            when 12
              # Sign the 8-bit value
              # If Bit7 is 1, subtract 256 from the value to get the negative equivalent
              # If Bit7 is 0, just use the positive number
              #
              @signed_byte = @unsigned_byte >= 128 ? @unsigned_byte - 256 : @unsigned_byte
            when 16
              cpu.registers.z_flag = false
              cpu.registers.n_flag = false
              cpu.registers.h_flag = ((cpu.registers.sp & 0x0F) + (@unsigned_byte & 0x0F)) > 0x0F
              cpu.registers.c_flag = ((cpu.registers.sp & 0xFF) + @unsigned_byte) > 0xFF

              cpu.registers.sp += @signed_byte
            else wait
            end
          end
        end
      end
    end
  end
end
