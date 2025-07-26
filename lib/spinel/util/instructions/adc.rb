# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to all possible Add with Carry (ADC) instructions
      #
      # ADC A, reg8 => Adds the value of a 8-bit register + carry into A
      # ADC A, (HL) => Adds the value that HL is pointing to in memory + carry into A
      # ADC A, imm8 => Adds the value of the next immediate byte + carry into A
      #
      class Adc
        attr_reader :mnemonic, :bytes, :cycles

        # @param operand_type [Symbol] Which type of operand (:reg8, :mem_hl, :imm8)
        # @param operand [Symbol] Register to operate on, is only used for :reg8 mode
        #
        def initialize(operand_type, operand = nil)
          @operand_type = operand_type
          @operand = operand

          @mnemonic = current_mnemonic
          @bytes = current_bytes
          @cycles = current_cycles
        end

        def execute(cpu)
          case @operand_type
          when :reg8   then adc_reg8(cpu)
          when :mem_hl then adc_mem_hl(cpu)
          when :imm8   then adc_imm8(cpu)
          else
            raise ArgumentError, "Invalid ADC operand type: #{@operand_type}."
          end
        end

        private

        def current_mnemonic
          case @operand_type
          when :reg8   then "ADC A,#{@operand.to_s.upcase}"
          when :mem_hl then 'ADC A,(HL)'
          when :imm8   then 'ADC A,imm8'
          end
        end

        def current_bytes
          @operand_type == :imm8 ? 2 : 1
        end

        def current_cycles
          @operand_type == :reg8 ? 4 : 8
        end

        # Unifies the logic of adding with carry and setting the flags
        # for all 3 ADC instructions
        #
        def adc(cpu, value)
          accumulator = cpu.registers.a
          carry_in = cpu.registers.c_flag
          result = accumulator + value + carry_in

          cpu.registers.z_flag = result.nobits?(0xFF)
          cpu.registers.n_flag = false
          cpu.registers.h_flag = ((accumulator & 0x0F) + (value & 0x0F) + carry_in) > 0x0F
          cpu.registers.c_flag = result > 0xFF

          cpu.registers.a = result
        end

        # M-Cycle 1 => Adds the value of a given register and the carry flag into A
        #
        def adc_reg8(cpu)
          reg8_value = cpu.registers.send(@operand)
          adc(cpu, reg8_value)
        end

        # M-Cycle 1 => Fetches the byte that HL is pointing to in memory
        # M-Cycle 2 => Adds the fetched value and the carry flag into A
        #
        def adc_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          adc(cpu, value_at_mem_hl)
        end

        # M-Cycle 1 => Fetches the next immediate byte from memory
        # M-Cycle 2 => Adds its value and the carry flag into A
        #
        def adc_imm8(cpu)
          immediate_byte = cpu.fetch_next_byte
          adc(cpu, immediate_byte)
        end
      end
    end
  end
end
