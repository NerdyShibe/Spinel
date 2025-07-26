# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to all possible Complement instructions
        #
        class Complement
          # @param operation [Symbol] Which type of Complement operation
          #
          def initialize(operation)
            @operation = operation

            super(
              mnemonic: metadata[:mnemonic],
              bytes: metadata[:bytes],
              cycles: metadata[:cycles]
            )
          end

          def execute(cpu)
            case @operation
            when :cpl then cpl(cpu)
            when :ccf then ccf(cpu)
            when :scf then scf(cpu)
            else raise ArgumentError, "Invalid Complement operation: #{@operation}."
            end
          end

          private

          def metadata
            case @operation
            when :cpl
              { mnemonic: 'CPL', bytes: 1, cycles: 4 }
            when :ccf
              { mnemonic: 'CCF', bytes: 1, cycles: 4 }
            when :scf
              { mnemonic: 'SCF', bytes: 1, cycles: 4 }
            end
          end

          def cpl(cpu)
            case cpu.ticks
            when 4
              cpu.registers.a = ~cpu.registers.a

              cpu.registers.n_flag = true
              cpu.registers.h_flag = true
            else wait
            end
          end

          # Flips the current value of the C Flag
          # Sets additional flags (N and H) to false
          #
          def ccf(cpu)
            case cpu.ticks
            when 4
              flipped_bit = cpu.registers.c_flag ^ 1

              cpu.registers.n_flag = false
              cpu.registers.h_flag = false
              cpu.registers.c_flag = (flipped_bit == 1)
            else wait
            end
          end

          # Sets the carry flag to 1
          # Also clears the N and H flag
          #
          def scf(cpu)
            case cpu.ticks
            when 4
              cpu.registers.n_flag = false
              cpu.registers.h_flag = false
              cpu.registers.c_flag = true
            else wait
            end
          end
        end
      end
    end
  end
end
