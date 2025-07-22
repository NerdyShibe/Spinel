# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Load Immediate 16-bit data to a 16-bit special register
        #
        class LdReg16Imm16 < Base
          def initialize(reg16)
            super(
              mnemonic: "LD #{reg16.to_s.upcase}, Imm16",
              bytes: 3,
              cycles: 12
            )

            @reg16 = reg16
          end

          def execute(cpu)
            case cpu.ticks
            when 5 then cpu.request_read
            when 8 then @lsb = cpu.receive_data
            when 9 then cpu.request_read
            when 12
              @msb = cpu.receive_data
              @imm16 = (@msb << 8) | @lsb

              puts "Loading 0x#{format('%04X', @imm16)} into #{@reg16.to_s.upcase} register"
              cpu.registers.set_value(@reg16, @imm16)
            else wait
            end
          end
        end
      end
    end
  end
end
