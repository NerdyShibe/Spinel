# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Defines all possible Increment (INC) instructions
        #
        class XorReg8 < Base
          def initialize(reg8)
            super(
              mnemonic: "XOR A, #{reg8.to_s.upcase}",
              length: 1,
              cycles: 4
            )

            @reg8 = reg8
          end

          def execute(cpu)
            case cpu.ticks
            when 4
              puts "Calculating #{mnemonic}..."
              result = cpu.registers.a ^ cpu.registers.send(@reg8)

              cpu.registers.z_flag = result.zero?
              cpu.registers.n_flag = false
              cpu.registers.h_flag = false
              cpu.registers.c_flag = false

              cpu.registers.a = result
            else
              wait
            end
          end
        end
      end
    end
  end
end
