# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Jump Relative based on a Signed 8-bit integer (-128 to +127)
        class JmpRelSig8 < Base
          # @param flag [Symbol] Register flag to check for the jump (:z_flag or :c_flag)
          # @param condition [Integer] Flag value to check for the Jump (0 or 1)
          def initialize(flag, condition)
            super(
              mnemonic: 'JR NZ, e8',
              bytes: 2,
              cycles: 8
            )

            @flag = flag
            @condition = condition
          end

          def execute(cpu)
            case cpu.ticks
            when 5 then cpu.request_read
            when 8
              @byte = cpu.receive_data

              if cpu.registers.send(@flag) == @condition
                puts "#{@flag} is #{@condition}, incrementing cycles to jump next..."
                self.cycles = 12
              else
                puts "#{@flag} was not #{@condition}, will not jump"
              end
            when 12
              @signed_offset = @byte >= 128 ? @byte - 256 : @byte
              puts "Adjusting program counter: #{format('%04X', cpu.registers.pc)} " \
                   "by #{@signed_offset}"
            else wait
            end
          end
        end
      end
    end
  end
end
