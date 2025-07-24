# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to all possible
        # Stack instructions
        #
        class Stack < Base
          # @param operation [Symbol] Which type of Stack
          #
          def initialize(operation, register)
            @operation = operation
            @register = register

            super(
              mnemonic: metadata[:mnemonic],
              bytes: metadata[:bytes],
              cycles: metadata[:cycles]
            )
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
          def push_reg16(cpu)
            case cpu.ticks
            when 5
              cpu.registers.sp -= 1
              cpu.request_write(cpu.registers.sp)
            when 8
              msb = cpu.registers.send(@register) >> 8
              cpu.confirm_write(msb)
            when 13 # rubocop:disable Lint/DuplicateBranch
              cpu.registers.sp -= 1
              cpu.request_write(cpu.registers.sp)
            when 16
              lsb = cpu.registers.send(@register) & 0xFF
              cpu.confirm_write(lsb)
            else wait
            end
          end

          # Pops 2 bytes from the stack into a 16-bit register
          # Increments the Stack Pointer each time
          #
          def pop_reg16(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.sp)
            when 8
              @lsb = cpu.receive_data
              cpu.registers.sp += 1
            when 9 then cpu.request_read(cpu.registers.sp) # rubocop:disable Lint/DuplicateBranch
            when 12
              msb = cpu.receive_data
              cpu.registers.sp += 1
              popped_value = (msb << 8) | @lsb

              cpu.registers.send("#{@register}=", popped_value)
            else wait
            end
          end
        end
      end
    end
  end
end
