# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to all possible Bit Shift instructions
        #
        class BitShifts < Base
          # @param operation [Symbol] Which type of Bit Shift operation
          # @param register [Symbol] 8-bit register to perform the operation, if any
          #
          def initialize(operation, register = nil)
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
            when :rlc         then rlc(cpu)
            when :rlc_mem_hl  then rlc_mem_hl(cpu)
            when :rrc         then rrc(cpu)
            when :rrc_mem_hl  then rrc_mem_hl(cpu)
            when :rl          then rl(cpu)
            when :rl_mem_hl   then rl_mem_hl(cpu)
            when :rr          then rr(cpu)
            when :rr_mem_hl   then rr_mem_hl(cpu)
            when :sla         then sla(cpu)
            when :sla_mem_hl  then sla_mem_hl(cpu)
            when :sra         then sra(cpu)
            when :sra_mem_hl  then sra_mem_hl(cpu)
            when :swap        then swap(cpu)
            when :swap_mem_hl then swap_mem_hl(cpu)
            when :srl         then srl(cpu)
            when :srl_mem_hl  then srl_mem_hl(cpu)
            else raise ArgumentError, "Invalid Bit Shift operation: #{@operation}."
            end
          end

          private

          def metadata
            case @operation
            when :rlc
              { mnemonic: "RLC #{@register.to_s.upcase}", bytes: 2, cycles: 8 }
            when :rlc_mem_hl
              { mnemonic: 'RLC [HL]', bytes: 2, cycles: 16 }
            when :rrc
              { mnemonic: "RRC #{@register.to_s.upcase}", bytes: 2, cycles: 8 }
            when :rrc_mem_hl
              { mnemonic: 'RRC [HL]', bytes: 2, cycles: 16 }
            when :rl
              { mnemonic: "RL #{@register.to_s.upcase}", bytes: 2, cycles: 8 }
            when :rl_mem_hl
              { mnemonic: 'RL [HL]', bytes: 2, cycles: 16 }
            when :rr
              { mnemonic: "RR #{@register.to_s.upcase}", bytes: 2, cycles: 8 }
            when :rr_mem_hl
              { mnemonic: 'RR [HL]', bytes: 2, cycles: 16 }
            when :sla
              { mnemonic: "SLA #{@register.to_s.upcase}", bytes: 2, cycles: 8 }
            when :sla_mem_hl
              { mnemonic: 'SLA [HL]', bytes: 2, cycles: 16 }
            when :sra
              { mnemonic: "SRA #{@register.to_s.upcase}", bytes: 2, cycles: 8 }
            when :sra_mem_hl
              { mnemonic: 'SRA [HL]', bytes: 2, cycles: 16 }
            when :swap
              { mnemonic: "SWAP #{@register.to_s.upcase}", bytes: 2, cycles: 8 }
            when :swap_mem_hl
              { mnemonic: 'SWAP [HL]', bytes: 2, cycles: 16 }
            when :srl
              { mnemonic: "SRL #{@register.to_s.upcase}", bytes: 2, cycles: 8 }
            when :srl_mem_hl
              { mnemonic: 'SRL [HL]', bytes: 2, cycles: 16 }
            end
          end

          def update_flags(cpu, result, bit_shifted)
            cpu.registers.z_flag = result.nobits?(0xFF)
            cpu.registers.n_flag = false
            cpu.registers.h_flag = false
            cpu.registers.c_flag = (bit_shifted == 1)
          end

          def rlc(cpu)
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

          def rrc(cpu)
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

          def rl(cpu)
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

          def rr(cpu)
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

          def swap(cpu)
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
