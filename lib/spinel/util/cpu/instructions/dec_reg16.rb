# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Defines all possible Increment (INC) instructions
        #
        class DecReg16 < Base
          def initialize(reg16)
            super(
              mnemonic: "DEC #{reg16.to_s.upcase}",
              bytes: 1,
              cycles: 8
            )

            @reg16 = reg16
          end

          def execute(cpu)
            case cpu.ticks
            when 8
              value = cpu.registers.send(@reg16)
              puts "Subtracting 1 from #{@reg16.to_s.upcase}: 0x#{format('%04X', value)}"
              result = (value - 1) & 0xFFFF

              cpu.registers.z_flag = result.zero?
              cpu.registers.n_flag = true
              cpu.registers.h_flag = value.nobits?(0x00FF)

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
