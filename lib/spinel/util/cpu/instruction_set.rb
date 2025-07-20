# rubocop:disable Lint/DuplicateBranch, Metrics/ModuleLength
# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      # Build the instructions
      module InstructionSet
        def self.build_unprefixed
          instructions = Array.new(256, Instructions::Unused.new)

          instructions[Opcodes::NOP]   = Instructions::Nop.new
          instructions[Opcodes::INC_B] = Instructions::IncReg8.new(:b)
          instructions[Opcodes::INC_D] = Instructions::IncReg8.new(:d)
          instructions[Opcodes::INC_H] = Instructions::IncReg8.new(:h)

          instructions[Opcodes::INC_C] = Instructions::IncReg8.new(:c)
          instructions[Opcodes::INC_E] = Instructions::IncReg8.new(:e)
          instructions[Opcodes::INC_L] = Instructions::IncReg8.new(:l)
          instructions[Opcodes::INC_A] = Instructions::IncReg8.new(:a)

          instructions
        end

        def wait
          puts 'Waiting...'
        end

        # Does nothing for 4 t-cycles (ticks)
        def nop
          wait
        end

        #
        # =============== Load instructions ===============
        #

        def load_r8_r8(target_reg, source_reg)
          source_reg_value = @registers.send(source_reg)
          @registers.send(target_reg, source_reg_value)
        end

        def load_r16_imm16(reg16)
          case @ticks
          when 5 then request_read
          when 8 then @lsb = receive_data
          when 9 then request_read
          when 12
            @msb = receive_data
            @registers.send(reg16, (@msb << 8) | @lsb)
          else wait
          end
        end

        #
        # =============== Jump instructions ===============
        #

        # M-Cycle 1 (Ticks 1-4): Fetches opcode and wait
        # M-Cycle 2 (Ticks 5-8): Fetches the LSB of the jump address and waits
        # M-Cycle 3 (Ticks 9-12): Fetches the MSB of the jump address and waits
        # M-Cycle 4 (Ticks 13-16): Constitutes the jump address from MSB and LSB and jumps to address
        #
        def jump_a16
          case @ticks
          when 5 then request_read
          when 8 then @lsb = @bus.return_data
          when 9 then request_read # rubocop:disable Lint/DuplicateBranch
          when 12 then @msb = @bus.return_data
          when 16
            @jump_address = (@msb << 8) | @lsb
            puts "Jumping to $#{format('%04X', @jump_address)} address"
            @registers.pc = @jump_address
          else
            wait
          end
        end

        #
        # =============== Arithmetic instructions ===============
        #

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

        # Addition
        #
        # Adds a given value to the A register
        # and stores it back into the A register
        # A = A + value
        #
        # Subtraction Flag is always set to 0
        # The other flags need to be calculated depending on the result
        #
        # @param value [Integer] => Value to be added
        #
        def add_a(value)
          puts "Adding #{format('%02X', value)} to A: #{format('%02X', @registers.a)}"

          # Calculate the Half Carry and Carry Flags before the operation
          #
          h_flag = ((@registers.a & 0x0F) + (value & 0x0F)) > 0x0F
          c_flag = (@registers.a + value) > 0xFF

          @registers.a += value

          z_flag = @registers.a.zero? ? 1 : 0
          n_flag = 0

          @registers.set_flags(z: z_flag, n: n_flag, h: h_flag, c: c_flag)
        end

        # 4 t-cycles
        # Uses the 8-bit value from a given register to add
        #
        # @param reg8 [Symbol] => 8-bit Register to be used
        #
        def add_a_r8(reg8)
          r8_value = @registers.send(reg8)
          add_a(r8_value)
        end

        # 8 t-cycles
        # Needs to fetch the next byte after the opcode
        # And uses that as value for the addition
        #
        def add_a_d8
          case @ticks
          when 5 then request_read
          when 6..7 then wait
          when 8
            byte = receive_data
            add_a(byte)
          end
        end

        # 8 t-cycles
        # Puts the value of the HL register onto the bus
        # Fetches the byte in memory from that address
        # Uses that byte value to perform the addition
        #
        def add_a_mem_hl
          case @ticks
          when 5 then request_read(@registers.hl)
          when 6..7 then wait
          when 8
            byte = receive_data
            add_a(byte)
          end
        end

        def add_hl(value)
          @registers.hl += value

          @registers.z_flag &= 1 # Zero Flag is unaffected
          @registers.n_flag = 0
        end

        # 8 t-cycles
        # Adds the value of one 16-bit special register (BC, DE, HL or SP)
        # into HL and the result is stored into HL
        #
        # HL = HL + r16
        #
        # @param operand [Symbol] => 16-bit special register to be used
        #
        def add_hl_r16(operand)
          case @ticks
          when 5..7 then wait
          when 8
            r16_value = @registers.send(operand)

            h_flag = ((@registers.hl & 0x0FFF) + (r16_value & 0x0FFF)) > 0x0FFF
            c_flag = (@registers.hl + r16_value) > 0xFFFF

            @registers.hl += r16_value

            z_flag &= 1 # Zero Flag is unaffected
            n_flag = 0

            @registers.set_flags(z: z_flag, n: n_flag, h: h_flag, c: c_flag)
          end
        end

        # 16 t-cycles
        #
        # r8 means that it is a 8-bit signed value
        # ranging from -128 to +127
        # SP = SP + signed_r8
        #
        # Always clears the Zero and Subtraction Flags
        #
        def add_sp_r8
          case @ticks
          when 5 then request_read
          when 8
            @unsigned_byte = receive_data
          when 12
            # Sign the 8-bit value
            # If Bit7 is 1, subtract 256 from the value to get the negative equivalent
            # If Bit7 is 0, just use the positive number
            #
            @signed_byte = @unsigned_byte >= 128 ? @unsigned_byte - 256 : @unsigned_byte
          when 16
            # Half Carry and Carry Flags are calculated before the operation
            # Isolating the lower byte/nibble from SP to compare
            #
            h_flag = ((@registers.sp & 0x0F) + (@signed_byte & 0x0F)) > 0xFF
            c_flag = ((@registers.sp & 0xFF) + @signed_byte) > 0xFF

            @registers.sp += @signed_byte

            z_flag = 0
            n_flag = 0

            @registers.set_flags(z: z_flag, n: n_flag, h: h_flag, c: c_flag)
          else
            wait
          end
        end

        # ========================================================================================
        # Addition with Carry (ADC)
        #
        # Adds a given value and the Carry Flag to the A register
        # and stores it back into the A register
        # A = A + value + c_flag
        #
        # Subtraction Flag is always set to 0
        # The other flags need to be calculated depending on the result
        #
        # @param value [Integer] => Value to be added
        #
        def adc_a(value)
          carry_in = @registers.c_flag

          # Calculate the Half Carry and Carry Flags before the operation
          #
          h_flag = ((@registers.a & 0x0F) + (value & 0x0F)) > 0x0F
          c_flag = (@registers.a + value) > 0xFF

          @registers.a += (value + carry_in)

          z_flag = @registers.a.zero? ? 1 : 0
          n_flag = 0

          @registers.set_flags(z: z_flag, n: n_flag, h: h_flag, c: c_flag)
        end

        # 4 t-cycles
        # Uses the 8-bit value from a given register for the addition with carry
        #
        # @param reg8 [Symbol] => 8-bit Register to be used
        #
        def adc_a_r8(reg8)
          reg8_value = @registers.send(reg8)
          adc_a(reg8_value)
        end

        # 8 t-cycles
        # Needs to fetch the next byte after the opcode
        # And uses that as value for the addition with carry
        #
        def adc_a_d8
          case @ticks
          when 5 then request_read
          when 6..7 then wait
          when 8
            byte = receive_data
            adc_a(byte)
          end
        end

        # 8 t-cycles
        # Puts the value of the HL register onto the bus
        # Fetches the byte in memory from that address
        # Uses that byte value to perform the addition with carry
        #
        def adc_a_mem_hl
          case @ticks
          when 5 then request_read(@registers.hl)
          when 6..7 then wait
          when 8
            byte = receive_data
            adc_a(byte)
          end
        end

        # ========================================================================================
        # Subtraction (SUB)
        #
        # Subtracts a given value from the A register
        # and stores it back into the A register
        # A = A - value
        #
        # Subtraction Flag is always set to 1
        # The other flags need to be calculated depending on the result
        #
        # @param value [Integer] => Value to subtract from A register
        def sub(value)
          puts "Subtracting #{format('%02X', value)} from #{format('%02X', @registers.a)}"

          # Calculate the Half Carry and Carry Flags before the operation
          #
          h_flag = (@registers.a & 0x0F) < (value & 0x0F)
          c_flag = @registers.a < value

          @registers.a -= value

          z_flag = @registers.a.zero? ? 1 : 0
          n_flag = 1

          @registers.set_flags(z: z_flag, n: n_flag, h: h_flag, c: c_flag)
        end

        # 4 t-cycles
        # Uses the 8-bit value from a given register for the subtraction
        #
        # @param reg8 [Symbol] => 8-bit Register to be used
        #
        def sub_r8(reg8)
          r8_value = @registers.send(reg8)
          sub(r8_value)
        end

        # 8 t-cycles
        # Needs to fetch the next byte after the opcode
        # And uses that as value for the subtraction
        #
        def sub_d8
          case @ticks
          when 5 then request_read
          when 6..7 then wait
          when 8
            byte = receive_data
            sub(byte)
          end
        end

        # 8 t-cycles
        # Puts the value of the HL register onto the bus
        # Fetches the byte in memory from that address
        # Uses that byte value to perform the subtraction
        #
        def sub_mem_hl
          case @ticks
          when 5 then request_read(@registers.hl)
          when 6..7 then wait
          when 8
            byte = receive_data
            sub(byte)
          end
        end

        # ========================================================================================
        # Subtraction with Carry (SBC)
        #
        # Subtracts the value of a given 8-bit register from the A register
        # Also subtracts the value of the carry flag and stores the result into A
        # A = A - value - c_flag
        #
        # Subtraction Flag is always set to 1
        # The other flags need to be calculated depending on the result
        #
        # @param value [Integer] => Value to subtract from A register
        #
        def sbc(value)
          carry_in = @registers.c_flag

          # Calculate the Half Carry and Carry Flags before the operation
          #
          h_flag = (@registers.a & 0x0F) < ((value & 0x0F) + carry_in)
          c_flag = @registers.a < (value + carry_in)

          @registers.a -= (value + carry_in)

          z_flag = @registers.a.zero? ? 1 : 0

          @registers.set_flags(z: z_flag, n: 1, h: h_flag, c: c_flag)
        end

        # 4 t-cycles
        # Uses the 8-bit value from a given register for the subtraction
        #
        # @param reg8 [Symbol]
        #
        def sbc_a_r8(reg8)
          r8_value = @registers.send(reg8)
          sbc(r8_value)
        end

        # 8 t-cycles
        # Needs to fetch the next byte after the opcode
        # And uses that as value for the subtraction
        #
        def sbc_a_d8
          case @ticks
          when 5 then request_read
          when 6..7 then wait
          when 8
            byte = receive_data
            sbc(byte)
          end
        end

        # 8 t-cycles
        # Puts the value of the HL register onto the bus
        # Fetches the byte in memory from that address
        # Uses that byte value to perform the subtraction
        #
        def sbc_a_mem_hl
          case @ticks
          when 5 then request_read(@registers.hl)
          when 6..7 then wait
          when 8
            byte = receive_data
            sbc(byte)
          end
        end

        # ========================================================================================
        # Increment (INC)
        #
        # Increments a given value from either a 8-bit register, 16-bit register or
        # 8-bit value from a 16-bit address
        #
        def inc_r8(operand)
          new_value = @registers.send(operand) + 1
          @registers.send(operand, new_value)
        end

        # ========================================================================================
        # Push into the Stack (PUSH)
        #
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
            @bus.write_byte(@registers.sp, @msb)
          when 13
            @lsb = @registers.send(operand) & 0xFF
            @registers.sp -= 1
            @bus.write_byte(@registers.sp, @lsb)
          else
            wait
          end
        end

        # ========================================================================================
        # Pop out of the Stack (POP)
        #
        # Pops 2 bytes from the stack into a 16-bit register
        # Increments the Stack Pointer each time
        #
        # @param operand [Symbol] => Setter method for a special register
        # Possible values: :af=, :bc=, :de=, :hl=
        #
        def pop_r16(operand)
          case @ticks
          when 5
            @lsb = fetch_byte
            @registers.sp += 1
          when 9
            @msb = fetch_byte
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
  end
end

# rubocop:enable Lint/DuplicateBranch, Metrics/ModuleLength
