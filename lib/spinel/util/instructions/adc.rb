# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to all possible ADC instructions
        #
        class Adc
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
            when :adc_a_reg8   then adc_a_reg8(cpu)
            when :adc_a_mem_hl then adc_a_mem_hl(cpu)
            when :adc_a_imm8   then adc_a_imm8(cpu)
            else
              raise ArgumentError, "Invalid Adc operation: #{@operation}."
            end
          end

          private

          def metadata
            case @operation
            when :adc_a_reg8
              { mnemonic: "ADC A, #{@register.to_s.upcase}", bytes: 1, cycles: 4 }
            when :adc_a_mem_hl
              { mnemonic: 'ADC A, [HL]', bytes: 1, cycles: 8 }
            when :adc_a_imm8
              { mnemonic: 'ADC A, imm8', bytes: 2, cycles: 8 }
            end
          end

          # Unifies the logic of adding with carry and setting the flags
          # for all 3 ADC instructions
          #
          def adc_a(cpu, value)
            accumulator = cpu.registers.a
            carry_in = cpu.registers.c_flag
            puts "Adding #{format('%02X', value)} (carry: #{carry_in}) to A: #{format('%02X', accumulator)}"
            result = accumulator + value + carry_in

            cpu.registers.z_flag = result.nobits?(0xFF)
            cpu.registers.n_flag = false
            cpu.registers.h_flag = ((accumulator & 0x0F) + (value & 0x0F) + carry_in) > 0x0F
            cpu.registers.c_flag = result > 0xFF

            cpu.registers.a = result
          end

          # Adds the value of a given register and the carry flag into A
          #
          def adc_a_reg8(cpu)
            case cpu.ticks
            when 4
              reg8_value = cpu.registers.send(@register)
              adc_a(cpu, reg8_value)
            else wait
            end
          end

          # Fetches the byte value that HL is pointing to in memory
          # Adds the value and the carry flag into A
          #
          def adc_a_mem_hl(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.hl)
            when 8
              value_at_mem_hl = cpu.receive_data
              adc_a(cpu, value_at_mem_hl)
            else wait
            end
          end

          # Fetches the next immediate byte from memory
          # Adds its value and the carry flag into A
          #
          def adc_a_imm8(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.pc)
            when 8
              immediate_byte = cpu.receive_data
              adc_a(cpu, immediate_byte)
            else wait
            end
          end
        end
      end
    end
  end
end
