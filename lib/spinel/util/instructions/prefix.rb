# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Prefixes the additional 256 Opcodes
        #
        class Prefix
          attr_reader :mnemonic, :bytes, :cycles

          def initialize
            @mnemonic = 'PREFIX'
            @bytes = 1
            @cycles = 4
          end

          # M-cycle 1 => Fetches opcode
          #
          def execute(cpu); end
        end
      end
    end
  end
end
