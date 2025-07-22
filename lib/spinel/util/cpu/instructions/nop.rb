# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Nop instruction
        #
        class Nop < Base
          def initialize
            super(mnemonic: 'NOP', bytes: 1, cycles: 4)
          end

          def execute(_cpu)
            puts 'Doing nothing...'
          end
        end
      end
    end
  end
end
