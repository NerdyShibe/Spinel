# frozen_string_literal: true

module Spinel
  #
  # Will hold the logic for all instructions
  #
  module InstructionHandler
    def wait
      puts 'Waiting...'
    end

    # Does nothing for 4 t-cycles (ticks)
    def nop
      case @ticks
      when 1..4
        wait
      end
    end

    def ld_r16_d16
      abort('Instruction not yet implemented: ld_r16_d16')
    end

    # M-Cycle 1 (Ticks 1-4): Fetches opcode and wait
    # M-Cycle 2 (Ticks 5-8): Fetches the LSB of the jump address and waits
    # M-Cycle 3 (Ticks 9-12): Fetches the MSB of the jump address and waits
    # M-Cycle 4 (Ticks 13-16): Constitutes the jump address from MSB and LSB and jumps to address
    #
    def jump_a16
      case @ticks
      when 5
        @lsb = fetch_byte
      when 9
        @msb = fetch_byte
      when 13
        puts 'Calculating jump address...'
        @jump_address = (@msb << 8) | @lsb
      when 16
        puts "Jumping to $#{format('%04X', @jump_address)} address"
        @registers.pc = @jump_address
      else
        wait
      end
    end

    # XOR operation with a given operand and the A register
    def xor_r(operand)
      case @ticks
      when 4
        puts "Operand: #{operand}, Register: #{@registers.send(operand)}"
        result = @registers.a ^ @registers.send(operand)
        @registers.a = result
        @registers.f_z = result.zero? ? 1 : 0
      else
        wait
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
    def push_r16(operand)
      case @ticks
      when 9
        @msb = (@registers.send(operand) >> 8) & 0xFF
        @registers.sp -= 1
        @bus.write(@registers.sp, @msb)
      when 13
        @lsb = @registers.send(operand) & 0xFF
        @registers.sp -= 1
        @bus.write(@registers.sp, @lsb)
      else
        wait
      end
    end

    # Pops 2 bytes from the stack into a 16-bit register
    # Increments the Stack Pointer each time
    #
    # @param operand [Symbol] => Setter method for a special register
    # Possible values: :af=, :bc=, :de=, :hl=
    #
    def pop_r16(operand)
      case @ticks
      when 5
        @lsb = @bus.read(@registers.sp)
        @registers.sp += 1
      when 9
        @msb = @bus.read(@registers.sp)
        @registers.sp += 1
      when 12
        value = (@msb << 8) | @lsb
        value &= operand == :af= ? 0xFFF0 : 0xFFFF
        @registers.send(operand, value)
      else
        wait
      end
    end

    # Disable interrupts for the Cpu
    def di
      case @ticks
      when 4
        puts 'Disabling interrupts...'
        @ime_flag = false
      end
    end
  end
end
