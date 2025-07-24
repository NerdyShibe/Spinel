# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to all possible CP instructions
        #
        class Compare < Base
          VALID_OPERATIONS = %i[
            cp_a_reg8
            cp_a_mem_hl
            cp_a_imm8
          ].freeze

          # @param operation [Symbol] Which type of CP operation
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
            when :cp_a_reg8   then cp_a_reg8(cpu)
            when :cp_a_mem_hl then cp_a_mem_hl(cpu)
            when :cp_a_imm8   then cp_a_imm8(cpu)
            end
          end

          private

          def validate(operation)
            return if VALID_OPERATIONS.include?(operation)

            raise ArgumentError, "Invalid CP operation: #{operation}. " \
                                 "Must be one of #{VALID_OPERATIONS.inspect}"
          end

          def metadata
            case @operation
            when :cp_a_reg8
              { mnemonic: "CP A, #{@register.to_s.upcase}", bytes: 1, cycles: 4 }
            when :cp_a_mem_hl
              { mnemonic: 'CP A, [HL]', bytes: 1, cycles: 8 }
            when :cp_a_imm8
              { mnemonic: 'CP A, imm8', bytes: 2, cycles: 8 }
            end
          end

          # Groups the CP logic and setting the Flags into a single method
          # Result is discared and not stores back into the Accumulator
          #
          def cp_a(cpu, value)
            accumulator = cpu.registers.a
            result = accumulator - value

            cpu.registers.z_flag = result.nobits?(0xFF)
            cpu.registers.n_flag = true
            cpu.registers.h_flag = (accumulator & 0x0F) < (value & 0x0F)
            cpu.registers.c_flag = accumulator < value
          end

          # Uses the value for a given 8-bit register
          # and performs the CP operation against the Accumulator
          #
          def cp_a_reg8(cpu)
            case cpu.ticks
            when 4
              reg8_value = cpu.registers.send(@register)
              puts "Performing CP on A: #{format('%08B', cpu.registers.a)} - " \
                   "#{@register.to_s.upcase}: #{format('%08B', reg8_value)}"
              cp_a(cpu, reg8_value)
            else wait
            end
          end

          # Fetch the byte which HL is pointing to in memory
          # And performs the CP operation with the Accumulator
          #
          def cp_a_mem_hl(cpu)
            case cpu.ticks
            when 5
              address = cpu.registers.hl
              cpu.request_read(address)
            when 8
              value_at_mem_hl = cpu.receive_data
              puts "Performing CP on A: #{format('%08B', cpu.registers.a)} - " \
                   "value at [HL]: #{format('%08B', value_at_mem_hl)}"
              cp_a(cpu, value_at_mem_hl)
            else wait
            end
          end

          # Fetches the immediate byte following the Opcode
          # And performs the CP operation with the Accumulator
          #
          def cp_a_imm8(cpu)
            case cpu.ticks
            when 5 then cpu.request_read
            when 8
              immediate_byte = cpu.receive_data
              puts "Performing CP on A: #{format('%08B', cpu.registers.a)} - " \
                   "Immediate byte: #{format('%08B', immediate_byte)}"
              cp_a(cpu, immediate_byte)
            else wait
            end
          end
        end
      end
    end
  end
end
