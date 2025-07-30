# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to all possible Bit Shift instructions
      #
      class BitShifts
        attr_reader :mnemonic, :bytes, :cycles

        # @param operation [Symbol] Which type of Bit Shift operation
        # @param operand [Symbol] Either a 8-bit register or :mem_hl => [HL]
        #
        def initialize(operation, operand)
          @operation = operation
          @operand = operand

          @mnemonic = current_mnemonic
          @bytes = current_bytes
          @cycles = current_cycles
        end

        def execute(cpu)
          case @operation
          when :rlc  then rlc(cpu)
          when :rrc  then rrc(cpu)
          when :rl   then rl(cpu)
          when :rr   then rr(cpu)
          when :sla  then sla(cpu)
          when :sra  then sra(cpu)
          when :swap then swap(cpu)
          when :srl  then srl(cpu)
          else raise ArgumentError, "Invalid Bit Shift operation: #{@operation}."
          end
        end

        private

        def current_mnemonic
          operand = @operand == :mem_hl ? '[HL]' : @operand
          [@operation, operand].join(' ').upcase
        end

        def current_bytes
          2
        end

        def current_cycles
          @operand == :mem_hl ? 16 : 8
        end

        def update_flags(cpu, result, bit_shifted)
          cpu.registers.z_flag = result.nobits?(0xFF)
          cpu.registers.n_flag = false
          cpu.registers.h_flag = false
          cpu.registers.c_flag = (bit_shifted == 1)
        end

        # Rotate Left Circular
        #
        def rlc(cpu)
          @operand == :mem_hl ? rlc_mem_hl(cpu) : rlc_reg8(cpu)
        end

        # Rotate Left Circular
        #
        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode and executes instruction
        #
        def rlc_reg8(cpu)
          register = cpu.registers.send(@operand)
          bit7 = (register >> 7) & 1

          result = (register << 1) | bit7

          update_flags(cpu, result, bit7)
          cpu.registers.send("#{@operand}=", result)
        end

        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode
        # M-cycle 3 => Read value from HL in memory and perform rotate
        # M-cycle 4 => Writes the value back at (HL)
        #
        def rlc_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          bit7 = (value_at_mem_hl >> 7) & 1

          rotated_value = (value_at_mem_hl << 1) | bit7

          update_flags(cpu, rotated_value, bit7)
          cpu.bus_write(cpu.registers.hl, rotated_value)
        end

        # Rotate Right Circular
        #
        def rrc(cpu)
          @operand == :mem_hl ? rrc_mem_hl(cpu) : rrc_reg8(cpu)
        end

        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode and executes instruction
        #
        def rrc_reg8(cpu)
          register = cpu.registers.send(@operand)
          bit0 = register & 1

          result = (bit0 << 7) | (register >> 1)

          update_flags(cpu, result, bit0)
          cpu.registers.send("#{@operand}=", result)
        end

        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode
        # M-cycle 3 => Read value from HL in memory and perform rotate
        # M-cycle 4 => Writes the value back at (HL)
        #
        def rrc_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          bit0 = value_at_mem_hl & 1

          rotated_value = (bit0 << 7) | (value_at_mem_hl >> 1)

          update_flags(cpu, rotated_value, bit0)
          cpu.bus_write(cpu.registers.hl, rotated_value)
        end

        # Rotate Left (Carry)
        #
        def rl(cpu)
          @operand == :mem_hl ? rl_mem_hl(cpu) : rl_reg8(cpu)
        end

        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode and executes instruction
        #
        def rl_reg8(cpu)
          register = cpu.registers.send(@operand)
          carry_in = cpu.registers.c_flag
          new_carry = (register >> 7) & 1

          result = (register << 1) | carry_in

          update_flags(cpu, result, new_carry)
          cpu.registers.send("#{@operand}=", result)
        end

        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode
        # M-cycle 3 => Read value from HL in memory and perform rotate
        # M-cycle 4 => Writes the value back at (HL)
        #
        def rl_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          carry_in = cpu.registers.c_flag
          new_carry = (value_at_mem_hl >> 7) & 1

          rotated_value = (value_at_mem_hl << 1) | carry_in

          update_flags(cpu, rotated_value, new_carry)
          cpu.bus_write(cpu.registers.hl, rotated_value)
        end

        # Rotate Right (Carry)
        #
        def rr(cpu)
          @operand == :mem_hl ? rr_mem_hl(cpu) : rr_reg8(cpu)
        end

        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode and executes instruction
        #
        def rr_reg8(cpu)
          register = cpu.registers.send(@operand)
          carry_in = cpu.registers.c_flag
          new_carry = register & 1

          result = (carry_in << 7) | (register >> 1)

          update_flags(cpu, result, new_carry)
          cpu.registers.send("#{@operand}=", result)
        end

        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode
        # M-cycle 3 => Read value from HL in memory and perform rotate
        # M-cycle 4 => Writes the value back at (HL)
        #
        def rr_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          carry_in = cpu.registers.c_flag
          new_carry = value_at_mem_hl & 1

          rotated_value = (carry_in << 7) | (value_at_mem_hl >> 1)

          update_flags(cpu, rotated_value, new_carry)
          cpu.bus_write(cpu.registers.hl, rotated_value)
        end

        # Shift Left Arithmetic
        #
        def sla(cpu)
          @operand == :mem_hl ? sla_mem_hl(cpu) : sla_reg8(cpu)
        end

        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode and executes instruction
        #
        def sla_reg8(cpu)
          register = cpu.registers.send(@operand)
          bit7 = (register >> 7) & 1

          result = (register << 1) | 0

          update_flags(cpu, result, bit7)
          cpu.registers.send("#{@operand}=", result)
        end

        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode
        # M-cycle 3 => Read value from HL in memory and perform rotate
        # M-cycle 4 => Writes the value back at (HL)
        #
        def sla_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          bit7 = (value_at_mem_hl >> 7) & 1

          rotated_value = (value_at_mem_hl << 1) | 0

          update_flags(cpu, rotated_value, bit7)
          cpu.bus_write(cpu.registers.hl, rotated_value)
        end

        # Shift Right Arithmetic
        #
        def sra(cpu)
          @operand == :mem_hl ? sra_mem_hl(cpu) : sra_reg8(cpu)
        end

        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode and executes instruction
        #
        def sra_reg8(cpu)
          reg8_value = cpu.registers.send(@operand)
          bit7 = (reg8_value >> 7) & 1
          bit0 = reg8_value & 1

          result = (bit7 << 7) | (reg8_value >> 1)

          update_flags(cpu, result, bit0)
          cpu.registers.send("#{@operand}=", result)
        end

        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode
        # M-cycle 3 => Read value from HL in memory and perform rotate
        # M-cycle 4 => Writes the value back at (HL)
        #
        def sra_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          bit7 = (value_at_mem_hl >> 7) & 1
          bit0 = value_at_mem_hl & 1

          rotated_value = (bit7 << 7) | (value_at_mem_hl >> 1)

          update_flags(cpu, rotated_value, bit0)
          cpu.bus_write(cpu.registers.hl, rotated_value)
        end

        # Swaps the Lower4 and Upper4 nibbles
        #
        def swap(cpu)
          @operand == :mem_hl ? swap_mem_hl(cpu) : swap_reg8(cpu)
        end

        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode and executes instruction
        #
        def swap_reg8(cpu)
          register = cpu.registers.send(@operand)
          lower4 = register & 0x0F
          upper4 = (register >> 4) & 0x0F

          result = (lower4 << 4) | upper4

          cpu.registers.z_flag = result.nobits?(0xFF)
          cpu.registers.n_flag = false
          cpu.registers.h_flag = false
          cpu.registers.c_flag = false

          cpu.registers.send("#{@operand}=", result)
        end

        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode
        # M-cycle 3 => Read value from HL in memory and perform rotate
        # M-cycle 4 => Writes the value back at (HL)
        #
        def swap_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          lower4 = value_at_mem_hl & 0x0F
          upper4 = (value_at_mem_hl >> 4) & 0x0F

          result = (lower4 << 4) | upper4

          cpu.registers.z_flag = result.nobits?(0xFF)
          cpu.registers.n_flag = false
          cpu.registers.h_flag = false
          cpu.registers.c_flag = false

          cpu.bus_write(cpu.registers.hl, result)
        end

        # Shift Right Logic
        #
        def srl(cpu)
          @operand == :mem_hl ? srl_mem_hl(cpu) : srl_reg8(cpu)
        end

        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode and executes instruction
        #
        def srl_reg8(cpu)
          register = cpu.registers.send(@operand)
          bit0 = register & 1

          result = (0 << 7) | (register >> 1)

          update_flags(cpu, result, bit0)
          cpu.registers.send("#{@operand}=", result)
        end

        # M-cycle 1 => Fetches 0xCB prefix opcode
        # M-cycle 2 => Fetches current opcode
        # M-cycle 3 => Read value from HL in memory and perform rotate
        # M-cycle 4 => Writes the value back at (HL)
        #
        def srl_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          bit0 = value_at_mem_hl & 1

          rotated_value = (0 << 7) | (value_at_mem_hl >> 1)

          update_flags(cpu, rotated_value, bit0)
          cpu.bus_write(cpu.registers.hl, rotated_value)
        end
      end
    end
  end
end
