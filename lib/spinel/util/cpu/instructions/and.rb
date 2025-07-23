# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to all possible AND instructions
        #
        class And < Base
          VALID_OPERATIONS = %i[
            and_a_reg8
            and_a_mem_hl
            and_a_imm8
          ].freeze

          # @param operation [Symbol] Which type of AND operation
          # @param register [Symbol] Register to execute the operation, if any
          #
          def initialize(operation, register = nil)
            validate(operation)

            @operation = operation
            @register = register

            super(
              mnemonic: metadata[:mnemonic],
              bytes: metadata[:bytes],
              cycles: metadata[:cycles]
            )
          end

          def execute(cpu)
            case @operation
            when :and_a_reg8   then and_a_reg8(cpu)
            when :and_a_mem_hl then and_a_mem_hl(cpu)
            when :and_a_imm8   then and_a_imm8(cpu)
            end
          end

          private

          def validate(operation)
            return if VALID_OPERATIONS.include?(operation)

            raise ArgumentError, "Invalid AND operation: #{operation}. " \
                                 "Must be one of #{VALID_OPERATIONS.inspect}"
          end

          def metadata
            case @operation
            when :and_a_reg8
              { mnemonic: "AND A, #{@register.to_s.upcase}", bytes: 1, cycles: 4 }
            when :and_a_mem_hl
              { mnemonic: 'AND A, [HL]', bytes: 1, cycles: 8 }
            when :and_a_imm8
              { mnemonic: 'AND A, imm8', bytes: 2, cycles: 8 }
            end
          end

          # Groups the AND logic and setting the Flags into a single method
          # Stores the result into the Accumulator
          #
          def and_a(cpu, value)
            accumulator = cpu.registers.a
            result = accumulator & value

            cpu.registers.z_flag = result.nobits?(0xFF)
            cpu.registers.n_flag = false
            cpu.registers.h_flag = true
            cpu.registers.c_flag = false

            cpu.registers.a = result
          end

          # Uses the value for a given 8-bit register
          # and performs the AND operation against the Accumulator
          #
          def and_a_reg8(cpu)
            case cpu.ticks
            when 4
              reg8_value = cpu.registers.send(@register)
              puts "Performing AND on A: #{format('%08B', cpu.registers.a)} & " \
                   "#{@register.to_s.upcase}: #{format('%08B', reg8_value)}"
              and_a(cpu, reg8_value)
            else wait
            end
          end

          # Fetch the byte which HL is pointing to in memory
          # And performs the AND operation with the Accumulator
          #
          def and_a_mem_hl(cpu)
            case cpu.ticks
            when 5
              address = cpu.registers.hl
              cpu.request_read(address)
            when 8
              value_at_mem_hl = cpu.receive_data
              puts "Performing AND on A: #{format('%08B', cpu.registers.a)} & " \
                   "value at [HL]: #{format('%08B', value_at_mem_hl)}"
              and_a(cpu, value_at_mem_hl)
            else wait
            end
          end

          # Fetches the immediate byte following the Opcode
          # And performs the AND operation with the Accumulator
          #
          def and_a_imm8(cpu)
            case cpu.ticks
            when 5 then cpu.request_read
            when 8
              immediate_byte = cpu.receive_data
              puts "Performing AND on A: #{format('%08B', cpu.registers.a)} & " \
                   "Immediate byte: #{format('%08B', immediate_byte)}"
              and_a(cpu, immediate_byte)
            else wait
            end
          end
        end
      end
    end
  end
end
