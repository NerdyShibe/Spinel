# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to all possible ADD instructions
        #
        class Inc < Base
          VALID_OPERATIONS = %i[
            inc_reg8
            inc_at_mem_hl
            inc_reg16
          ].freeze

          # @param operation [Symbol] Which type of increment
          # @param register [Symbol] Register to perform the operation
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

          # @param cpu [Object] Instance of the Cpu to perform the instruction
          #
          def execute(cpu)
            case @operation
            when :inc_reg8      then inc_reg8(cpu)
            when :inc_at_mem_hl then inc_at_mem_hl(cpu)
            when :inc_reg16     then inc_reg16(cpu)
            end
          end

          private

          def validate(operation)
            return if VALID_OPERATIONS.include?(operation)

            raise ArgumentError, "Invalid INC operation: #{operation}. " \
                                 "Must be one of #{VALID_OPERATIONS.inspect}"
          end

          def metadata
            case @operation
            when :inc_reg8
              { mnemonic: "INC #{@register.to_s.upcase}", bytes: 1, cycles: 4 }
            when :inc_at_mem_hl
              { mnemonic: 'INC [HL]', bytes: 1, cycles: 12 }
            when :inc_reg16
              { mnemonic: "INC #{@register.to_s.upcase}", bytes: 1, cycles: 8 }
            end
          end

          # @param cpu [Object] Instance of the Cpu
          # @param result [Integer] Result of the operation (increment)
          # @param original_value [Integer] Previous value, before the increment
          #
          def update_flags(cpu, result, original_value)
            cpu.registers.z_flag = result.nobits?(0xFF)
            cpu.registers.n_flag = false
            cpu.registers.h_flag = original_value.allbits?(0x0F)
          end

          # Increments a given 8-bit register
          #
          def inc_reg8(cpu)
            case cpu.ticks
            when 4
              reg8_value = cpu.registers.send(@register)
              puts "Adding 1 to #{@register.to_s.upcase}: #{format('%02X', reg8_value)}"
              result = reg8_value + 1

              update_flags(cpu, result, reg8_value)

              cpu.registers.send("#{@register}=", result)
            else wait
            end
          end

          # Increments the value that HL is pointing to in memory
          #
          def inc_at_mem_hl(cpu)
            case cpu.ticks
            when 5
              @address = cpu.registers.hl
              cpu.request_read(@address)
            when 8 then @value_at_mem_hl = cpu.receive_data
            when 12
              puts "Adding 1 to the value at [HL]: #{format('%02X', @value_at_mem_hl)}"
              result = @value_at_mem_hl + 1

              update_flags(cpu, result, @value_at_mem_hl)

              cpu.request_write(@address, result)
            else wait
            end
          end

          # Increments a given 16-bit special register
          # Does not affect the registers flags
          #
          def inc_reg16(cpu)
            case cpu.ticks
            when 8
              reg16_value = cpu.registers.send(@register)
              puts "Adding 1 to #{@register.to_s.upcase}: #{format('%04X', reg16_value)}"
              result = reg16_value + 1

              cpu.registers.send("#{@register}=", result)
            else wait
            end
          end
        end
      end
    end
  end
end
