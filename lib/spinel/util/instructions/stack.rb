# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to all possible
      # Stack instructions
      #
      class Stack
        attr_reader :mnemonic, :bytes, :cycles

        # @param operation [Symbol] Which type of Stack
        #
        def initialize(operation, register)
          @operation = operation
          @register = register

          @mnemonic = metadata[:mnemonic]
          @bytes = metadata[:bytes]
          @cycles = metadata[:cycles]
        end

        def execute(cpu)
          case @operation
          when :push_reg16 then push_reg16(cpu)
          when :pop_reg16  then pop_reg16(cpu)
          else
            raise ArgumentError, "Invalid Stack operation: #{@operation}."
          end
        end

        private

        def metadata
          case @operation
          when :push_reg16
            { mnemonic: "PUSH #{@register.to_s.upcase}", bytes: 1, cycles: 16 }
          when :pop_reg16
            { mnemonic: "POP #{@register.to_s.upcase}", bytes: 1, cycles: 12 }
          end
        end

        # Push the value from one of the 16-bit special registers into the stack
        # Takes 4 m-cycles or 16 t-cycles
        #
        # Decrement the Stack Pointer first
        # Grab the Lower 8 bits of the value and push into the stack
        # Decrement the Stack Pointer again
        # Grab the Higher 8 bits of the value and push into the stack
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Internal delay ???
        # M-cycle 3 => Writes the most significant byte first
        # M-cycle 4 => Writes the less significant byte after
        #
        def push_reg16(cpu)
          reg16_value = cpu.registers.send(@register)
          reg16_msb = (reg16_value >> 8) & 0xFF
          reg16_lsb = reg16_value & 0xFF

          cpu.internal_delay

          cpu.registers.sp -= 1
          cpu.bus_write(cpu.registers.sp, reg16_msb)

          cpu.registers.sp -= 1
          cpu.bus_write(cpu.registers.sp, reg16_lsb)
        end

        # Pops 2 bytes from the stack into a 16-bit register
        # Increments the Stack Pointer each time
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Reads the less significant byte from the stack
        # M-cycle 3 => Reads the msb after and stores the value into the register
        #
        def pop_reg16(cpu)
          lsb = cpu.bus_read(cpu.registers.sp)
          cpu.registers.sp += 1

          msb = cpu.bus_read(cpu.registers.sp)
          cpu.registers.sp += 1
          popped_value = (msb << 8) | lsb

          cpu.registers.send("#{@register}=", popped_value)
        end
      end
    end
  end
end
