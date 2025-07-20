# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Defines all possible Increment (INC) instructions
        #
        class IncReg16 < Base
          def initialize(reg16)
            super(
              mnemonic: "INC #{reg16.to_s.upcase}",
              length: 1,
              cycles: 8
            )

            @reg16 = reg16
          end

          def execute(cpu)
            case cpu.ticks
            when 8
              value = cpu.registers.send(@reg16)
              result = (value + 1) & 0xFFFF

              cpu.registers.z_flag = result.zero?
              cpu.registers.n_flag = false
              cpu.registers.h_flag = ((value & 0x00FF) + 1) > 0x00FF

              cpu.registers.set_value(@reg16, result)
            else
              wait
            end
          end
        end
      end
    end
  end
end
