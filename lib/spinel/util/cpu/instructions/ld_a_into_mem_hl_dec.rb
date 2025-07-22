# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Load Immediate 16-bit data to a 16-bit special register
        #
        class LdAIntoMemHlDec < Base
          def initialize
            super(
              mnemonic: 'LD [HL-], A',
              bytes: 1,
              cycles: 8
            )
          end

          def execute(cpu)
            case cpu.ticks
            when 5 then @address = cpu.registers.hl
            when 8
              cpu.request_write(@address, cpu.registers.a)
              cpu.registers.hl -= 1
            else wait
            end
          end
        end
      end
    end
  end
end
