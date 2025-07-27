# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to all possible AND instructions
      #
      # AND A, reg8 => Performs a Bitwise And with A and a 8-bit register
      # AND A, (HL) => Performs a Bitwise And with A and the value at (HL)
      # AND A, imm8 => Performs a Bitwise And with A and the next immediate byte
      #
      class And
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
          when :reg8   then and_a_reg8(cpu)
          when :mem_hl then and_a_mem_hl(cpu)
          when :imm8   then and_a_imm8(cpu)
          else
            raise ArgumentError, "Invalid AND operation type: #{@operand_type}"
          end
        end

        private

        def current_mnemonic
          case @operand_type
          when :reg8   then "AND A,#{@operand.to_s.upcase}"
          when :mem_hl then 'AND A,(HL)'
          when :imm8   then 'AND A,imm8'
          end
        end

        def current_bytes
          @operand_type == :imm8 ? 2 : 1
        end

        def current_cycles
          @operand_type == :reg8 ? 4 : 8
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

        # M-Cycle 1 => Fetches opcode and performs the AND with A and a 8-bit register
        #
        def and_a_reg8(cpu)
          reg8_value = cpu.registers.send(@operand)
          and_a(cpu, reg8_value)
        end

        # M-Cycle 1 => Fetches opcode
        # M-Cycle 2 => Fetches byte at (HL) and performs the AND with A
        #
        def and_a_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          and_a(cpu, value_at_mem_hl)
        end

        # M-Cycle 1 => Fetches opcode
        # M-Cycle 2 => Fetches next immediate byte and performs the AND with A
        #
        def and_a_imm8(cpu)
          immediate_byte = cpu.fetch_next_byte
          and_a(cpu, immediate_byte)
        end
      end
    end
  end
end
