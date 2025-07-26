# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Executes the 0x00 => NOP Instruction
      #
      # 1 M-cycle (4 T-cycles) => Fetch opcode and do nothing
      #
      class Nop
        attr_reader :mnemonic, :bytes, :t_cycles

        def initialize
          @mnemonic = 'NOP'
          @bytes = 1
          @t_cycles = 4
        end

        def execute(_cpu); end
      end
    end
  end
end
