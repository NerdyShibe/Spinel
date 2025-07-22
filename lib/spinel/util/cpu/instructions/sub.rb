# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to all possible SUB instructions
        #
        class Sub < Base
          VALID_OPERATIONS = %i[
            sub_a_reg8
            sub_a_mem_hl
            sub_a_imm8
          ].freeze

          # @param operation [Symbol] Which type of Subtraction
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
            when :sub_a_reg8   then sub_a_reg8(cpu)
            when :sub_a_mem_hl then sub_a_mem_hl(cpu)
            when :sub_a_imm8   then sub_a_imm8(cpu)
            end
          end

          private

          # TODO: Validate operand also? Use respond_to? maybe
          def validate(operation)
            return if VALID_OPERATIONS.include?(operation)

            raise ArgumentError, "Invalid SUB operation: #{operation}. " \
                                 "Must be one of #{VALID_OPERATIONS.inspect}"
          end

          def metadata
            case @operation
            when :sub_a_reg8
              { mnemonic: "SUB A, #{@operand.to_s.upcase}", bytes: 1, cycles: 4 }
            when :sub_a_mem_hl
              { mnemonic: 'SUB A, [HL]', bytes: 1, cycles: 8 }
            when :sub_a_imm8
              { mnemonic: 'SUB A, imm8', bytes: 2, cycles: 8 }
            end
          end

          # Groups the Subtracting logic and setting the Flags into a single method
          #
          def sub_a(cpu, value)
            accumulator = cpu.registers.a
            puts "Subtracting #{format('%02X', value)} from A: #{format('%02X', accumulator)}"
            result = (accumulator - value) & 0xFF

            cpu.registers.z_flag = result.zero?
            cpu.registers.n_flag = true
            cpu.registers.h_flag = (accumulator & 0x0F) < (value & 0x0F)
            cpu.registers.c_flag = accumulator < value

            cpu.registers.a = result
          end

          # Subtracts the value from a given 8-bit register from the Accumulator
          #
          def sub_a_reg8(cpu)
            case cpu.ticks
            when 4
              reg8_value = cpu.registers.send(@operand)
              sub_a(cpu, reg8_value)
            else wait
            end
          end

          # Fetch the byte which HL is pointing to in memory
          # And subtracts the value from the Accumulator
          #
          def sub_a_mem_hl(cpu)
            case cpu.ticks
            when 5
              address = cpu.registers.hl
              cpu.request_read(address)
            when 8
              value_at_mem_hl = cpu.receive_data
              sub_a(cpu, value_at_mem_hl)
            else wait
            end
          end

          # Fetches the immediate byte following the Opcode
          # And subtracts the value from the Accumulator
          #
          def sub_a_imm8(cpu)
            case cpu.ticks
            when 5 then cpu.request_read
            when 8
              immediate_byte = cpu.receive_data
              sub_a(cpu, immediate_byte)
            else wait
            end
          end
        end
      end
    end
  end
end
