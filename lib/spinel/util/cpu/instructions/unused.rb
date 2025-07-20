# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        #
        # Unused opcodes
        class Unused < Base
          def initialize
            super(mnemonic: 'UNUSED', length: 1, cycles: 4)
          end

          def execute(cpu)
            opcode = format('%02X', cpu.opcode)
            raise NotImplementedError, "0x#{opcode} was not implemented yet..."
          end
        end
      end
    end
  end
end
