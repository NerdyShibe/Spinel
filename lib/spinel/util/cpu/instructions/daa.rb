# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to the DAA instruction
        #
        class Daa < Base
          def initialize
            super(
              mnemonic: metadata[:mnemonic],
              bytes: metadata[:bytes],
              cycles: metadata[:cycles]
            )
          end

          def execute(cpu)
            case cpu.ticks
            when 4
              accumulator = cpu.registers.a
              correction = 0x00
              carry_in = cpu.registers.c_flag
              new_carry = false

              if cpu.registers.n_flag == 1
                correction |= 0x06 if cpu.registers.h_flag == 1
                correction |= 0x60 if cpu.registers.c_flag == 1

                bcd_adjusted = accumulator - correction
              else
                correction |= 0x06 if cpu.registers.h_flag == 1 || (accumulator & 0x0F) > 0x09

                if cpu.registers.c_flag == 1 || (accumulator & 0xFF) > 0x99
                  correction |= 0x60
                  new_carry = true
                end

                bcd_adjusted = accumulator + correction
              end

              cpu.registers.z_flag = bcd_adjusted.nobits?(0xFF)
              cpu.registers.h_flag = false
              cpu.registers.c_flag = new_carry || carry_in == 1

              cpu.registers.a = bcd_adjusted
            else wait
            end
          end

          private

          def metadata
            { mnemonic: 'DAA', bytes: 1, cycles: 4 }
          end
        end
      end
    end
  end
end
