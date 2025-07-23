# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to all possible SBC instructions
        #
        class Sbc < Base
          # @param operation [Symbol] Which type of Addition
          # @param register [Symbol]
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
            puts "Subtracting #{format('%02X', value)} (carry: #{carry_in}) to A: #{format('%02X', accumulator)}"
            result = accumulator - (value + carry_in)

            cpu.registers.z_flag = result.nobits?(0xFF)
            cpu.registers.n_flag = true
            cpu.registers.h_flag = (accumulator & 0x0F) < (value & 0x0F) + carry_in
            cpu.registers.c_flag = accumulator < value + carry_in

            cpu.registers.a = result
          end

          # Subtracts the value of a given register and the carry flag from A
          #
          def sbc_a_reg8(cpu)
            case cpu.ticks
            when 4
              reg8_value = cpu.registers.send(@register)
              sbc_a(cpu, reg8_value)
            else wait
            end
          end

          # Fetches the byte value that HL is pointing to in memory
          # Subtracts the value and the carry flag from A
          #
          def sbc_a_mem_hl(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.hl)
            when 8
              value_at_mem_hl = cpu.receive_data
              sbc_a(cpu, value_at_mem_hl)
            else wait
            end
          end

          # Fetches the next immediate byte from memory
          # Subtracts its value and the carry flag from A
          #
          def sbc_a_imm8(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.pc)
            when 8
              immediate_byte = cpu.receive_data
              sbc_a(cpu, immediate_byte)
            else wait
            end
          end
        end
      end
    end
  end
end
