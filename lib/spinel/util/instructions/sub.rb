# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to all possible SUB instructions
      #
      class Sub
        attr_reader :mnemonic, :bytes, :cycles

        # @param operation [Symbol] Which type of Subtraction
        # @param register [Symbol]
        #
        def initialize(operation, register = nil)
          @operation = operation
          @register = register

          @mnemonic = metadata[:mnemonic]
          @bytes = metadata[:bytes]
          @cycles = metadata[:cycles]
        end

        def execute(cpu)
          case @operation
          when :sub_a_reg8   then sub_a_reg8(cpu)
          when :sub_a_mem_hl then sub_a_mem_hl(cpu)
          when :sub_a_imm8   then sub_a_imm8(cpu)
          else
            raise ArgumentError, "Invalid SUB operation: #{@operation}."
          end
        end

        private

        def metadata
          case @operation
          when :sub_a_reg8
            { mnemonic: "SUB A, #{@register.to_s.upcase}", bytes: 1, cycles: 4 }
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
          result = accumulator - value

          cpu.registers.z_flag = result.nobits?(0xFF)
          cpu.registers.n_flag = true
          cpu.registers.h_flag = (accumulator & 0x0F) < (value & 0x0F)
          cpu.registers.c_flag = accumulator < value

          cpu.registers.a = result
        end

        # Subtracts the value from a given 8-bit register from the Accumulator
        #
        # M-cycle 1 => Fetches opcode and performs the subtraction
        #
        def sub_a_reg8(cpu)
          reg8_value = cpu.registers.send(@register)
          sub_a(cpu, reg8_value)
        end

        # Fetch the byte which HL is pointing to in memory
        # And subtracts the value from the Accumulator
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Reads value at (HL) and performs the subtraction
        #
        def sub_a_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          sub_a(cpu, value_at_mem_hl)
        end

        # Fetches the immediate byte following the Opcode
        # And subtracts the value from the Accumulator
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Reads next immediate byte and performs the sub
        #
        def sub_a_imm8(cpu)
          immediate_byte = cpu.fetch_next_byte
          sub_a(cpu, immediate_byte)
        end
      end
    end
  end
end
