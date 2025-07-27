# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to all possible ADD instructions
      #
      class Inc
        attr_reader :mnemonic, :bytes, :cycles

        # @param operation [Symbol] Which type of increment
        # @param register [Symbol] Register to perform the operation
        #
        def initialize(operation, register = nil)
          @operation = operation
          @register = register

          @mnemonic = metadata[:mnemonic]
          @bytes = metadata[:bytes]
          @cycles = metadata[:cycles]
        end

        # @param cpu [Object] Instance of the Cpu to perform the instruction
        #
        def execute(cpu)
          case @operation
          when :inc_reg8   then inc_reg8(cpu)
          when :inc_mem_hl then inc_mem_hl(cpu)
          when :inc_reg16  then inc_reg16(cpu)
          else
            raise ArgumentError, "Invalid INC operation: #{@operation}."
          end
        end

        private

        def metadata
          case @operation
          when :inc_reg8
            { mnemonic: "INC #{@register.to_s.upcase}", bytes: 1, cycles: 4 }
          when :inc_mem_hl
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

        # M-cycle 1 => Fetches opcode and increments a given 8-bit register
        #
        def inc_reg8(cpu)
          reg8_value = cpu.registers.send(@register)
          result = reg8_value + 1

          update_flags(cpu, result, reg8_value)

          cpu.registers.send("#{@register}=", result)
        end

        # Increments the value that HL is pointing to in memory
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Reads the value at (HL)
        # M-cycle 3 => Increments the value and writes it back to (HL)
        #
        def inc_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          result = value_at_mem_hl + 1

          update_flags(cpu, result, value_at_mem_hl)

          cpu.bus_write(cpu.registers.hl, result)
        end

        # Increments a given 16-bit special register
        # Does not affect the registers flags
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Performs the 16-bit addition
        #
        def inc_reg16(cpu)
          reg16_value = cpu.registers.send(@register)
          result = cpu.add16(reg16_value, 1)

          cpu.registers.send("#{@register}=", result)
        end
      end
    end
  end
end
