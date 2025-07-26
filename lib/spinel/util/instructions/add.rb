# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to all possible Add with Carry (ADD) instructions
      #
      # ADD A, reg8 => Adds the value of a 8-bit register into A
      # ADD A, (HL) => Adds the value that HL is pointing to in memory into A
      # ADD A, imm8 => Adds the value of the next immediate byte into A
      #
      class Add
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
          when :reg8     then add_reg8(cpu)
          when :mem_hl   then add_mem_hl(cpu)
          when :imm8     then add_imm8(cpu)
          when :hl_reg16 then add_hl_reg16(cpu)
          when :sp_sig8  then add_sp_sig8(cpu)
          end
        end

        private

        def current_mnemonic
          case @operand_type
          when :reg8     then "ADD A,#{@operand.to_s.upcase}"
          when :mem_hl   then 'ADD A,(HL)'
          when :imm8     then 'ADD A,imm8'
          when :hl_reg16 then "ADD HL,#{@operand.to_s.upcase}"
          when :sp_sig8  then 'ADD SP,sig8'
          end
        end

        def current_bytes
          return 2 if %i[sp_sig8 imm8].include?(@operand_type)

          1
        end

        def current_cycles
          return 4 if @operand_type == :reg8
          return 16 if @operand_type == :sp_sig8

          8
        end

        def add(cpu, value)
          accumulator = cpu.registers.a
          result = accumulator + value

          cpu.registers.z_flag = result.nobits?(0xFF)
          cpu.registers.n_flag = false
          cpu.registers.h_flag = ((accumulator & 0x0F) + (value & 0x0F)) > 0x0F
          cpu.registers.c_flag = result > 0xFF

          cpu.registers.a = result
        end

        # M-Cycle 1 => Fetches opcode and performs the addition
        #
        def add_reg8(cpu)
          reg8_value = cpu.registers.send(@operand)
          add(cpu, reg8_value)
        end

        # M-Cycle 1 => Fetches the opcode
        # M-Cycle 2 => Fetches the byte at (HL) and performs the addition
        #
        def add_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          add(cpu, value_at_mem_hl)
        end

        # M-Cycle 1 => Fetches the opcode
        # M-Cycle 2 => Fetches the next immediate byte and performs the addition
        #
        def add_imm8(cpu)
          immediate_byte = cpu.fetch_next_byte
          add(cpu, immediate_byte)
        end

        # M-Cycle 1 => Fetches the opcode
        # M-Cycle 2 => Calculates 16-bit addition and set flags
        #
        def add_hl_reg16(cpu)
          reg16_value = cpu.registers.send(@operand)
          hl_value = cpu.registers.hl
          result = cpu.calculate_add16(hl_value, reg16_value)

          cpu.registers.n_flag = false
          cpu.registers.h_flag = ((hl_value & 0x0FFF) + (reg16_value & 0x0FFF)) > 0x0FFF
          cpu.registers.c_flag = result > 0xFFFF

          cpu.registers.hl = result
        end

        # M-Cycle 1 => Fetches the opcode
        # M-Cycle 2 => Fetches the next immediate byte
        # M-Cycle 3 => Signs the value (-128 to +127)
        # M-Cycle 4 => Calculates 16-bit addition and set flags
        #
        def add_sp_sig8(cpu)
          sp_value = cpu.registers.sp
          unsigned_byte = cpu.fetch_next_byte
          signed_byte = cpu.sign_value(unsigned_byte)
          result = cpu.calculate_add16(sp_value, signed_byte)

          cpu.registers.z_flag = false
          cpu.registers.n_flag = false
          cpu.registers.h_flag = ((sp_value & 0x0F) + (unsigned_byte & 0x0F)) > 0x0F
          cpu.registers.c_flag = ((sp_value & 0xFF) + unsigned_byte) > 0xFF

          cpu.registers.sp = result
        end
      end
    end
  end
end
