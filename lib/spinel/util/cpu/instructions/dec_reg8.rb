# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Decrements the value of a given 8-bit register
        #
        class DecReg8 < Base
          def initialize(reg8)
            super(
              mnemonic: "DEC #{reg8.to_s.upcase}",
              bytes: 1,
              cycles: 4
            )

            @reg8 = reg8
          end

          def execute(cpu)
            value = cpu.registers.send(@reg8)
            puts "Subtracting 1 from #{@reg8.to_s.upcase}: 0x#{format('%02X', value)}"
            result = (value - 1) & 0xFF

            cpu.registers.z_flag = result.zero?
            cpu.registers.n_flag = true
            cpu.registers.h_flag = value.nobits?(0x0F) # requires a borrow

            cpu.registers.set_value(@reg8, result)
          end
        end
      end
    end
  end
end
