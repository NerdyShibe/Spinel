# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to all possible Bit Shift instructions
        #
        class BitShifts
          # @param operation [Symbol] Which type of Bit Shift operation
          # @param operand [Symbol] Either a 8-bit register or :mem_hl => [HL]
          #
          def initialize(operation, operand)
            @operation = operation
            @operand = operand

            super(
              mnemonic: current_mnemonic,
              bytes: current_bytes,
              cycles: current_cycles
            )
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

          def rlc_reg8(cpu)
            case cpu.ticks
            when 8
              register = cpu.registers.send(@register)
              bit7 = (register >> 7) & 1

              result = (register << 1) | bit7

              update_flags(cpu, result, bit7)
              cpu.registers.send("#{@register}=", result)
            else wait
            end
          end

          def rlc_mem_hl(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.hl)
            when 8 then @fetched_byte = cpu.receive_data
            when 12
              bit7 = (@fetched_byte >> 7) & 1

              @rotated_value = (@fetched_byte << 1) | bit7

              update_flags(cpu, @rotated_value, bit7)
            when 13 then cpu.request_write(cpu.registers.hl)
            when 16
              cpu.confirm_write(@rotated_value)
            else wait
            end
          end

          # Rotate Right Circular
          #
          def rrc(cpu)
            @operand == :mem_hl ? rrc_mem_hl(cpu) : rrc_reg8(cpu)
          end

          def rrc_reg8(cpu)
            case cpu.ticks
            when 8
              register = cpu.registers.send(@register)
              bit0 = register & 1

              result = (bit0 << 7) | (register >> 1)

              update_flags(cpu, result, bit0)
              cpu.registers.send("#{@register}=", result)
            else wait
            end
          end

          def rrc_mem_hl(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.hl)
            when 8 then @fetched_byte = cpu.receive_data
            when 12
              bit0 = @fetched_byte & 1

              @rotated_value = (bit0 << 7) | (@fetched_byte >> 1)

              update_flags(cpu, @rotated_value, bit0)
            when 13 then cpu.request_write(cpu.registers.hl)
            when 16
              cpu.confirm_write(@rotated_value)
            else wait
            end
          end

          # Rotate Left (Carry)
          #
          def rl(cpu)
            @operand == :mem_hl ? rl_mem_hl(cpu) : rl_reg8(cpu)
          end

          def rl_reg8(cpu)
            case cpu.ticks
            when 8
              register = cpu.registers.send(@register)
              carry_in = cpu.registers.c_flag
              new_carry = (register >> 7) & 1

              result = (register << 1) | carry_in

              update_flags(cpu, result, new_carry)
              cpu.registers.send("#{@register}=", result)
            else wait
            end
          end

          def rl_mem_hl(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.hl)
            when 8 then @fetched_byte = cpu.receive_data
            when 12
              carry_in = cpu.registers.c_flag
              new_carry = (@fetched_byte >> 7) & 1

              @rotated_value = (@fetched_byte << 1) | carry_in

              update_flags(cpu, @rotated_value, new_carry)
            when 13 then cpu.request_write(cpu.registers.hl)
            when 16
              cpu.confirm_write(@rotated_value)
            else wait
            end
          end

          # Rotate Right (Carry)
          #
          def rr(cpu)
            @operand == :mem_hl ? rr_mem_hl(cpu) : rr_reg8(cpu)
          end

          def rr_reg8(cpu)
            case cpu.ticks
            when 8
              register = cpu.registers.send(@register)
              carry_in = cpu.registers.c_flag
              new_carry = register & 1

              result = (carry_in << 7) | (register >> 1)

              update_flags(cpu, result, new_carry)
              cpu.registers.send("#{@register}=", result)
            else wait
            end
          end

          def rr_mem_hl(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.hl)
            when 8 then @fetched_byte = cpu.receive_data
            when 12
              carry_in = cpu.registers.c_flag
              new_carry = @fetched_byte & 1

              @rotated_value = (carry_in << 7) | (@fetched_byte >> 1)

              update_flags(cpu, @rotated_value, new_carry)
            when 13 then cpu.request_write(cpu.registers.hl)
            when 16
              cpu.confirm_write(@rotated_value)
            else wait
            end
          end

          # Shift Left Arithmetic
          #
          def sla(cpu)
            @operand == :mem_hl ? sla_mem_hl(cpu) : sla_reg8(cpu)
          end

          def sla_reg8(cpu)
            case cpu.ticks
            when 8
              register = cpu.registers.send(@register)
              bit7 = (register >> 7) & 1

              result = (register << 1) | 0

              update_flags(cpu, result, bit7)
              cpu.registers.send("#{@register}=", result)
            else wait
            end
          end

          def sla_mem_hl(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.hl)
            when 8 then @fetched_byte = cpu.receive_data
            when 12
              bit7 = (@fetched_byte >> 7) & 1

              @rotated_value = (@fetched_byte << 1) | 0

              update_flags(cpu, @rotated_value, bit7)
            when 13 then cpu.request_write(cpu.registers.hl)
            when 16
              cpu.confirm_write(@rotated_value)
            else wait
            end
          end

          # Shift Right Arithmetic
          #
          def sra(cpu)
            @operand == :mem_hl ? sra_mem_hl(cpu) : sra_reg8(cpu)
          end

          def sra_reg8(cpu)
            case cpu.ticks
            when 8
              register = cpu.registers.send(@register)
              bit7 = (register >> 7) & 1
              bit0 = register & 1

              result = (bit7 << 7) | (register >> 1)

              update_flags(cpu, result, bit0)
              cpu.registers.send("#{@register}=", result)
            else wait
            end
          end

          def sra_mem_hl(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.hl)
            when 8 then @fetched_byte = cpu.receive_data
            when 12
              bit7 = (@fetched_byte >> 7) & 1
              bit0 = @fetched_byte & 1

              @rotated_value = (bit7 << 7) | (@fetched_byte >> 1)

              update_flags(cpu, @rotated_value, bit0)
            when 13 then cpu.request_write(cpu.registers.hl)
            when 16
              cpu.confirm_write(@rotated_value)
            else wait
            end
          end

          # Swaps the Lower4 and Upper4 nibbles
          #
          def swap(cpu)
            @operand == :mem_hl ? swap_mem_hl(cpu) : swap_reg8(cpu)
          end

          def swap_reg8(cpu)
            case cpu.ticks
            when 8
              register = cpu.registers.send(@register)
              lower4 = register & 0x0F
              upper4 = register >> 4

              result = (lower4 << 4) | upper4
              cpu.registers.send("#{@register}=", result)

              cpu.registers.z_flag = result.nobits?(0xFF)
              cpu.registers.n_flag = false
              cpu.registers.h_flag = false
              cpu.registers.c_flag = false
            else wait
            end
          end

          def swap_mem_hl(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.hl)
            when 8 then @fetched_byte = cpu.receive_data
            when 12
              lower4 = @fetched_byte & 0x0F
              upper4 = @fetched_byte >> 4

              @result = (lower4 << 4) | upper4
            when 13 then cpu.request_write(cpu.registers.hl)
            when 16
              cpu.confirm_write(@result)
              cpu.registers.z_flag = @result.nobits?(0xFF)
              cpu.registers.n_flag = false
              cpu.registers.h_flag = false
              cpu.registers.c_flag = false
            else wait
            end
          end

          # Shift Right Logic
          #
          def srl(cpu)
            @operand == :mem_hl ? srl_mem_hl(cpu) : srl_reg8(cpu)
          end

          def srl_reg8(cpu)
            case cpu.ticks
            when 8
              register = cpu.registers.send(@register)
              bit0 = register & 1

              result = 0 | (register >> 1)

              update_flags(cpu, result, bit0)
              cpu.registers.send("#{@register}=", result)
            else wait
            end
          end

          def srl_mem_hl(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.hl)
            when 8 then @fetched_byte = cpu.receive_data
            when 12
              bit0 = @fetched_byte & 1

              @rotated_value = 0 | (@fetched_byte >> 1)

              update_flags(cpu, @rotated_value, bit0)
            when 13 then cpu.request_write(cpu.registers.hl)
            when 16
              cpu.confirm_write(@rotated_value)
            else wait
            end
          end
        end
      end
    end
  end
end
