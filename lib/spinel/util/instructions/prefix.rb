# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        #
        # Not Implemented instructions
        class Prefix
          def initialize
            super(mnemonic: 'PREFIX', bytes: 1, cycles: 4)
          end

          def execute(cpu)
            case cpu.ticks
            when 4
              cpu.cb_prefix_mode = true
            else wait
            end
          end
        end
      end
    end
  end
end
