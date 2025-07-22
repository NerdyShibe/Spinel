# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Base Instruction
        class Base
          attr_accessor :cycles
          attr_reader :mnemonic, :bytes

          def initialize(mnemonic:, bytes:, cycles:)
            @mnemonic = mnemonic
            @bytes = bytes
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
