# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Defines all possible Increment (INC) instructions
        #
        class IncAtMemHl < Base
          def initialize
            super(
              mnemonic: 'INC [HL]',
              length: 1,
              cycles: 12
            )
          end

          def execute(cpu)
            case cpu.ticks
            when 5
              @address = cpu.registers.hl
              cpu.request_read(@address)
            when 8 then @value = cpu.receive_data
            when 9 then @value += 1
            when 12 then cpu.bus.write_byte(@address, @value)
            else wait
            end
          end
        end
      end
    end
  end
end
