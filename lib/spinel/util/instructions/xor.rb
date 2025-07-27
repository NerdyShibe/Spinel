# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to all possible XOR instructions
      #
      class Xor
        attr_reader :mnemonic, :bytes, :cycles

        # @param operation [Symbol] Which type of XOR operation
        # @param register [Symbol] Register to execute the operation, if any
        #
        def initialize(operation, register = nil)
          @operation = operation
          @register = register

          @mnemonic = metadata[:mnemonic]
          @bytes = metadata[:bytes]
          @cycles = metadata[:cycles]
        end

        def execute(cpu)
          case @operation
          when :xor_a_reg8   then xor_a_reg8(cpu)
          when :xor_a_mem_hl then xor_a_mem_hl(cpu)
          when :xor_a_imm8   then xor_a_imm8(cpu)
          else
            raise ArgumentError, "Invalid XOR operation: #{@operation}."
          end
        end

        private

        def metadata
          case @operation
          when :xor_a_reg8
            { mnemonic: "XOR A, #{@register.to_s.upcase}", bytes: 1, cycles: 4 }
          when :xor_a_mem_hl
            { mnemonic: 'XOR A, [HL]', bytes: 1, cycles: 8 }
          when :xor_a_imm8
            { mnemonic: 'XOR A, imm8', bytes: 2, cycles: 8 }
          end
        end

        # Groups the XOR logic and setting the Flags into a single method
        # Stores the result into the Accumulator
        #
        def xor_a(cpu, value)
          accumulator = cpu.registers.a
          result = accumulator ^ value

          cpu.registers.z_flag = result.nobits?(0xFF)
          cpu.registers.n_flag = false
          cpu.registers.h_flag = false
          cpu.registers.c_flag = false

          cpu.registers.a = result
        end

        # Uses the value for a given 8-bit register
        # and performs the XOR operation against the Accumulator
        #
        # M-cycle 1 => Fetches opcode and performs the XOR
        #
        def xor_a_reg8(cpu)
          reg8_value = cpu.registers.send(@register)
          xor_a(cpu, reg8_value)
        end

        # Fetch the byte which HL is pointing to in memory
        # And performs the XOR operation with the Accumulator
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Read value at (HL) and perform the XOR
        #
        def xor_a_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          xor_a(cpu, value_at_mem_hl)
        end

        # Fetches the immediate byte following the Opcode
        # And performs the XOR operation with the Accumulator
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Fetch next immediate byte and perform the XOR
        #
        def xor_a_imm8(cpu)
          immediate_byte = cpu.fetch_next_byte
          xor_a(cpu, immediate_byte)
        end
      end
    end
  end
end
