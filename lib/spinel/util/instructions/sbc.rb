# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to all possible SBC instructions
      #
      class Sbc
        attr_reader :mnemonic, :bytes, :cycles

        # @param operation [Symbol] Which type of Addition
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
          when :sbc_a_reg8   then sbc_a_reg8(cpu)
          when :sbc_a_mem_hl then sbc_a_mem_hl(cpu)
          when :sbc_a_imm8   then sbc_a_imm8(cpu)
          else
            raise ArgumentError, "Invalid SBC operation: #{@operation}."
          end
        end

        private

        def metadata
          case @operation
          when :sbc_a_reg8
            { mnemonic: "SBC A, #{@register.to_s.upcase}", bytes: 1, cycles: 4 }
          when :sbc_a_mem_hl
            { mnemonic: 'SBC A, [HL]', bytes: 1, cycles: 8 }
          when :sbc_a_imm8
            { mnemonic: 'SBC A, imm8', bytes: 2, cycles: 8 }
          end
        end

        # Unifies the logic of adding with carry and setting the flags
        # for all 3 SBC instructions
        #
        def sbc_a(cpu, value)
          accumulator = cpu.registers.a
          carry_in = cpu.registers.c_flag
          result = accumulator - (value + carry_in)

          cpu.registers.z_flag = result.nobits?(0xFF)
          cpu.registers.n_flag = true
          cpu.registers.h_flag = (accumulator & 0x0F) < (value & 0x0F) + carry_in
          cpu.registers.c_flag = accumulator < value + carry_in

          cpu.registers.a = result
        end

        # Subtracts the value of a given register and the carry flag from A
        #
        # M-cycle 1 => Fetches opcode and performs the subtraction with carry
        #
        def sbc_a_reg8(cpu)
          reg8_value = cpu.registers.send(@register)
          sbc_a(cpu, reg8_value)
        end

        # Fetches the byte value that HL is pointing to in memory
        # Subtracts the value and the carry flag from A
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Reads value at (HL) and performs the subtraction w/ carry
        #
        def sbc_a_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          sbc_a(cpu, value_at_mem_hl)
        end

        # Fetches the next immediate byte from memory
        # Subtracts its value and the carry flag from A
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Fetches next byte and performs the subtraction w/ carry
        #
        def sbc_a_imm8(cpu)
          immediate_byte = cpu.fetch_next_byte
          sbc_a(cpu, immediate_byte)
        end
      end
    end
  end
end
