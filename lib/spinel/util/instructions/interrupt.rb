# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to all possible
      # Interrupt instructions
      #
      class Interrupt
        # @param operation [Symbol] Which type of Interrupt
        #
        def initialize(operation)
          @operation = operation

          @mnemonic = metadata[:mnemonic]
          @bytes = metadata[:bytes]
          @cycles = metadata[:cycles]
        end

        def execute(cpu)
          case @operation
          when :stop then stop(cpu)
          when :halt then halt(cpu)
          when :di   then di(cpu)
          when :ei   then ei(cpu)
          else
            raise ArgumentError, "Invalid Interrupt operation: #{@operation}."
          end
        end

        private

        def metadata
          case @operation # rubocop:disable Style/HashLikeCase
          when :stop
            { mnemonic: 'STOP imm8', bytes: 2, cycles: 4 }
          when :halt
            { mnemonic: 'HALT', bytes: 1, cycles: 4 }
          when :di
            { mnemonic: 'DI', bytes: 1, cycles: 4 }
          when :ei
            { mnemonic: 'EI', bytes: 1, cycles: 4 }
          end
        end

        # Stops the cpu execution
        # Is 2 bytes long so it needs to increment the PC
        #
        # M-cycle 1 => Fetches opcode and execute instruction
        #
        def stop(cpu)
          cpu.stopped = true
          cpu.registers.pc += 1
        end

        # Halts the Cpu execution
        #
        # M-cycle 1 => Fetches opcode and execute instruction
        #
        def halt(cpu)
          cpu.halted = true
        end

        # Disable interrupts
        # Sets @ime_flag = false in the cpu, but only
        # on the last tick of the next instruction
        #
        # M-cycle 1 => Fetches opcode and execute instruction
        #
        def di(cpu)
          cpu.ime_flag_schedule = :disable
        end

        # Enable interrupts
        # Sets @ime_flag = true in the cpu, but only
        # on the last tick of the next instruction
        #
        # M-cycle 1 => Fetches opcode and execute instruction
        #
        def ei(cpu)
          cpu.ime_flag_schedule = :enable
        end
      end
    end
  end
end
