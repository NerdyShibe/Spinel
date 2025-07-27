# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to all possible CP instructions
      #
      class Compare
        attr_reader :mnemonic, :bytes, :cycles

        # @param operation [Symbol] Which type of CP operation
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
          when :cp_a_reg8   then cp_a_reg8(cpu)
          when :cp_a_mem_hl then cp_a_mem_hl(cpu)
          when :cp_a_imm8   then cp_a_imm8(cpu)
          else
            raise ArgumentError, "Invalid CP operation: #{@operation}."
          end
        end

        private

        def metadata
          case @operation
          when :cp_a_reg8
            { mnemonic: "CP A, #{@register.to_s.upcase}", bytes: 1, cycles: 4 }
          when :cp_a_mem_hl
            { mnemonic: 'CP A, [HL]', bytes: 1, cycles: 8 }
          when :cp_a_imm8
            { mnemonic: 'CP A, imm8', bytes: 2, cycles: 8 }
          end
        end

        # Groups the CP logic and setting the Flags into a single method
        # Result is discared and not stores back into the Accumulator
        #
        def cp_a(cpu, value)
          accumulator = cpu.registers.a
          result = accumulator - value

          cpu.registers.z_flag = result.nobits?(0xFF)
          cpu.registers.n_flag = true
          cpu.registers.h_flag = (accumulator & 0x0F) < (value & 0x0F)
          cpu.registers.c_flag = accumulator < value
        end

        # Uses the value for a given 8-bit register
        # and performs the CP operation against the Accumulator
        #
        # M-cycle 1 => Fetches opcode and perform operation
        #
        def cp_a_reg8(cpu)
          reg8_value = cpu.registers.send(@register)
          cp_a(cpu, reg8_value)
        end

        # Fetch the byte which HL is pointing to in memory
        # And performs the CP operation with the Accumulator
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Reads the value at (HL) and compares with A
        #
        def cp_a_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          cp_a(cpu, value_at_mem_hl)
        end

        # Fetches the immediate byte following the Opcode
        # And performs the CP operation with the Accumulator
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Fetches next immediate byte and compares with A
        #
        def cp_a_imm8(cpu)
          immediate_byte = cpu.fetch_next_byte
          cp_a(cpu, immediate_byte)
        end
      end
    end
  end
end
