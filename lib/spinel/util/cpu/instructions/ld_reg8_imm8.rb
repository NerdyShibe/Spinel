# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Load Immediate 8-bit data to a 8-bit register
        #
        class LdReg8Imm8 < Base
          def initialize(reg8)
            super(
              mnemonic: "LD #{reg8.to_s.upcase}, Imm8",
              bytes: 2,
              cycles: 8
            )

            @reg8 = reg8
          end

          def execute(cpu)
            case cpu.ticks
            when 5 then cpu.request_read
            when 8
              @imm8 = cpu.receive_data
              puts "Loading 0x#{format('%02X', @imm8)} into #{@reg8.to_s.upcase} register"
              cpu.registers.set_value(@reg8, @imm8)
            else wait
            end
          end
        end
      end
    end
  end
end
