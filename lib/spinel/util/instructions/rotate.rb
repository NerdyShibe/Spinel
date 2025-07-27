# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to all possible Rotate instructions
      #
      class Rotate
        attr_reader :mnemonic, :bytes, :cycles

        # @param operation [Symbol] Which type of Rotate operation
        #
        def initialize(operation)
          @operation = operation

          @mnemonic = metadata[:mnemonic]
          @bytes = metadata[:bytes]
          @cycles = metadata[:cycles]
        end

        def execute(cpu)
          case @operation
          when :rlca then rlca(cpu)
          when :rla  then rla(cpu)
          when :rrca then rrca(cpu)
          when :rra  then rra(cpu)
          else raise ArgumentError, "Invalid Rotate operation: #{@operation}."
          end
        end

        private

        def metadata
          case @operation
          when :rlca
            { mnemonic: 'RLCA', bytes: 1, cycles: 4 }
          when :rla
            { mnemonic: 'RLA', bytes: 1, cycles: 4 }
          when :rrca
            { mnemonic: 'RRCA', bytes: 1, cycles: 4 }
          when :rra
            { mnemonic: 'RRA', bytes: 1, cycles: 4 }
          end
        end

        def update_flags(cpu, bit_shifted)
          cpu.registers.z_flag = false
          cpu.registers.n_flag = false
          cpu.registers.h_flag = false
          cpu.registers.c_flag = (bit_shifted == 1)
        end

        # M-cycle 1 => Fetch opcode and rotate bits left
        #
        def rlca(cpu)
          accumulator = cpu.registers.a
          bit7 = (accumulator >> 7) & 1

          # Rotate left and wrap bit 7 to bit 0
          result = (accumulator << 1) | bit7

          update_flags(cpu, bit7)
          cpu.registers.a = result
        end

        # M-cycle 1 => Fetch opcode and rotate bits left with carry
        #
        def rla(cpu)
          accumulator = cpu.registers.a
          carry_in = cpu.registers.c_flag

          new_carry = (accumulator >> 7) & 1

          # Rotate left and bring the carry in into bit 0
          result = (accumulator << 1) | carry_in

          update_flags(cpu, new_carry)
          cpu.registers.a = result
        end

        # M-cycle 1 => Fetch opcode and rotate bits right
        #
        def rrca(cpu)
          accumulator = cpu.registers.a
          bit0 = accumulator & 1

          # Wrap bit 0 around to bit 7 and rotate right
          result = (bit0 << 7) | (accumulator >> 1)

          update_flags(cpu, bit0)
          cpu.registers.a = result
        end

        # M-cycle 1 => Fetch opcode and rotate bits right with carry
        #
        def rra(cpu)
          accumulator = cpu.registers.a
          carry_in = cpu.registers.c_flag

          new_carry = accumulator & 1

          # Bring the old carry as bit7 and rotate right
          result = (carry_in << 7) | (accumulator >> 1)

          update_flags(cpu, new_carry)
          cpu.registers.a = result
        end
      end
    end
  end
end
