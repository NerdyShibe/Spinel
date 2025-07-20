# frozen_string_literal: true

module Spinel
  module Cpu
    module Instructions
      # Base Instruction
      class Base
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
