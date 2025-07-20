# frozen_string_literal: true

module Spinel
  module Cpu
    module Instructions
      # Defines all possible Increment (INC) instructions
      #
      class Increment
        def initialize(cycles:, action:, operand:)
          @cycles = cycles
          @action = action
          @operand = operand
          @cpu_registers = nil
        end

        def execute(cpu)
          debugger
          send(@action, cpu)
        end

        def increment(value)
          result = value + 1

          @cpu_registers.z_flag = result.zero?
          @cpu_registers.n_flag = false
          @cpu_registers.h_flag = ((value & 0xF0) + 1) > 0xF0
        end

        # Increments a 8-bit special register (:a, :b, :c, :d, :e, :h, :l)
        # Takes the default 4 ticks to complete
        #
        # @param operand [Symbol] The 8-bit register to increment
        #
        def inc_r8(cpu)
          value = cpu.registers.send(@operand) + 1
          cpu.registers.set_value(@operand, value)
        end

        # Increments a 16-bit special register (:bc, :de, :hl, :sp)
        # Takes 8 ticks to complete
        #
        # @param operand [Symbol] The 16-bit register to increment
        #
        def inc_r16(cpu)
          case cpu.ticks
          when 8
            value = cpu.registers.send(@operand) + 1
            cpu.registers.set_value(@operand, value)
          else
            wait
          end
        end

        # Uses the 16-bit value from the HL register as a memory address
        # Fetches the 8-bit value from memory on that address and increments that
        # Takes 12 ticks to complete
        #
        def inc_at_mem_hl(cpu)
          case cpu.ticks
          when 5
            @address = cpu.registers.hl
            cpu.request_read(@address)
          when 8 then @value = cpu.receive_data
          when 9 then @value += 1
          when 12 then cpu.bus.write_byte(@address, @value)
          else wait
          end
        end
      end
    end
  end
end
