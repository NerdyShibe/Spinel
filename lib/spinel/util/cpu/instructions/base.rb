# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Base Instruction
        class Base
          attr_reader :mnemonic, :length, :cycles

          def initialize(mnemonic:, length:, cycles:)
            @mnemonic = mnemonic
            @length = length
            @cycles = cycles
          end

          def wait
            puts 'Waiting...'
          end
        end
      end
    end
  end
end
