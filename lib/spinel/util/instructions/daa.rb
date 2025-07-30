# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to the DAA instruction
      #
      class Daa
        attr_reader :mnemonic, :bytes, :cycles

        def initialize
          @mnemonic = metadata[:mnemonic]
          @bytes = metadata[:bytes]
          @cycles = metadata[:cycles]
        end

        # Decimal Adjust Accumulator
        #
        # Is used after performing a given arithmetic operation (ADD, SUB, ADC, SBC)
        # whose inputs were in Binary-Coded Decimal (BCD)
        # So after running this instruction the numbers would be adjusted to BCD format
        #
        # This instruction never clears the Carry flag (1 => 0)
        # It either preserves the value (0 => 0), (1 => 1) or sets it (0 => 1)
        #
        def execute(cpu)
          accumulator = cpu.registers.a
          carry_in = cpu.registers.c_flag
          new_carry = carry_in == 1
          bcd_correction = 0x00

          if cpu.registers.n_flag == 1
            bcd_correction |= 0x06 if cpu.registers.h_flag == 1
            bcd_correction |= 0x60 if cpu.registers.c_flag == 1

            bcd_adjusted = accumulator - bcd_correction
          else
            bcd_correction |= 0x06 if cpu.registers.h_flag == 1 || (accumulator & 0x0F) > 0x09

            if cpu.registers.c_flag == 1 || (accumulator & 0xFF) > 0x99
              bcd_correction |= 0x60
              new_carry = true
            end

            bcd_adjusted = accumulator + bcd_correction
          end

          cpu.registers.z_flag = bcd_adjusted.nobits?(0xFF)
          cpu.registers.h_flag = false
          cpu.registers.c_flag = new_carry

          cpu.registers.a = bcd_adjusted
        end

        private

        def metadata
          { mnemonic: 'DAA', bytes: 1, cycles: 4 }
        end
      end
    end
  end
end
