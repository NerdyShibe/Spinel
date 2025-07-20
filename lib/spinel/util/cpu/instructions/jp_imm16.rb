# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Jump Immediate 16-bit
        #
        class JpImm16 < Base
          def initialize
            super(mnemonic: 'JP Imm16', length: 3, cycles: 16)
          end

          def execute(cpu)
            case cpu.ticks
            when 5 then cpu.request_read
            when 8 then @lsb = cpu.receive_data
            when 9 then cpu.request_read
            when 12 then @msb = cpu.receive_data
            when 13 then @address = (@msb << 8) | @lsb
            when 16
              puts "Jumping to 0x#{format('%04X', @address)} address..."
              cpu.registers.pc = @address
            else wait
            end
          end
        end
      end
    end
  end
end
