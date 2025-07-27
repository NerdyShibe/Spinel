# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to all possible Complement instructions
      #
      class Complement
        attr_reader :mnemonic, :bytes, :cycles

        # @param operation [Symbol] Which type of Complement operation
        #
        def initialize(operation)
          @operation = operation

          @mnemonic = metadata[:mnemonic]
          @bytes = metadata[:bytes]
          @cycles = metadata[:cycles]
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

        # M-cycle 1 => Flips the bits of the A register
        def cpl(cpu)
          cpu.registers.a = ~cpu.registers.a

          cpu.registers.n_flag = true
          cpu.registers.h_flag = true
        end

        # M-cycle 1 => Flips the current value of the C Flag
        # Sets additional flags (N and H) to false
        #
        def ccf(cpu)
          flipped_bit = cpu.registers.c_flag ^ 1

          cpu.registers.n_flag = false
          cpu.registers.h_flag = false
          cpu.registers.c_flag = (flipped_bit == 1)
        end

        # M-cycle 1 => Sets the carry flag to 1
        # Also clears the N and H flag
        #
        def scf(cpu)
          cpu.registers.n_flag = false
          cpu.registers.h_flag = false
          cpu.registers.c_flag = true
        end
      end
    end
  end
end
