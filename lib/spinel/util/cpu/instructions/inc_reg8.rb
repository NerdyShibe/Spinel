# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Defines all possible Increment (INC) instructions
        #
        class IncReg8 < Base
          def initialize(reg8)
            super(
              mnemonic: "INC #{reg8.to_s.upcase}",
              length: 1,
              cycles: 4
            )

            @reg8 = reg8
          end

          def execute(cpu)
            value = cpu.registers.send(@reg8)
            result = (value + 1) & 0xFF

            cpu.registers.z_flag = result.zero?
            cpu.registers.n_flag = false
            cpu.registers.h_flag = ((value & 0x0F) + 1) > 0x0F

            cpu.registers.set_value(@reg8, result)
          end
        end
      end
    end
  end
end
