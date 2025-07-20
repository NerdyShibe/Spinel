# rubocop:disable Lint/DuplicateBranch, Metrics/ModuleLength
# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      # Build the instructions
      module InstructionSet
        def self.build_unprefixed
          instructions = Array.new(256, Instructions::Unused.new)

          # Opcodes: 0x00 - 0x0F
          instructions[0x00] = Instructions::Nop.new
          instructions[0x01] = Instructions::LdReg16Imm16.new(:bc)
          instructions[0x02]
          instructions[0x03]
          instructions[0x04] = Instructions::IncReg8.new(:b)
          instructions[0x05]
          instructions[0x06] = Instructions::LdReg8Imm8.new(:b)
          instructions[0x07]
          instructions[0x08]
          instructions[0x09]
          instructions[0x0A]
          instructions[0x0B]
          instructions[0x0C] = Instructions::IncReg8.new(:c)
          instructions[0x0D]
          instructions[0x0E] = Instructions::LdReg8Imm8.new(:c)
          instructions[0x0F]

          # Opcodes: 0x10 - 0x1F
          instructions[0x10]
          instructions[0x11] = Instructions::LdReg16Imm16.new(:de)
          instructions[0x12]
          instructions[0x13]
          instructions[0x14] = Instructions::IncReg8.new(:d)
          instructions[0x15]
          instructions[0x16] = Instructions::LdReg8Imm8.new(:d)
          instructions[0x17]
          instructions[0x18]
          instructions[0x19]
          instructions[0x1A]
          instructions[0x1B]
          instructions[0x1C] = Instructions::IncReg8.new(:e)
          instructions[0x1D]
          instructions[0x1E] = Instructions::LdReg8Imm8.new(:e)
          instructions[0x1F]

          # Opcodes: 0x20 - 0x2F
          instructions[0x20]
          instructions[0x21] = Instructions::LdReg16Imm16.new(:hl)
          instructions[0x22]
          instructions[0x23]
          instructions[0x24] = Instructions::IncReg8.new(:h)
          instructions[0x25]
          instructions[0x26] = Instructions::LdReg8Imm8.new(:h)
          instructions[0x27]
          instructions[0x28]
          instructions[0x29]
          instructions[0x2A]
          instructions[0x2B]
          instructions[0x2C] = Instructions::IncReg8.new(:l)
          instructions[0x2D]
          instructions[0x2E] = Instructions::LdReg8Imm8.new(:l)
          instructions[0x2F]

          # Opcodes: 0x30 - 0x3F
          instructions[0x30]
          instructions[0x31] = Instructions::LdReg16Imm16.new(:sp)
          instructions[0x32]
          instructions[0x33]
          instructions[0x34]
          instructions[0x35]
          instructions[0x36]
          instructions[0x37]
          instructions[0x38]
          instructions[0x39]
          instructions[0x3A]
          instructions[0x3B]
          instructions[0x3C] = Instructions::IncReg8.new(:a)
          instructions[0x3D]
          instructions[0x3E] = Instructions::LdReg8Imm8.new(:a)
          instructions[0x3F]

          # Opcodes: 0x40 - 0x4F
          # Opcodes: 0x50 - 0x5F
          # Opcodes: 0x60 - 0x6F
          # Opcodes: 0x70 - 0x7F
          # Opcodes: 0x80 - 0x8F
          # Opcodes: 0x90 - 0x9F

          # Opcodes: 0xA0 - 0xAF
          instructions[0xA8] = Instructions::XorReg8.new(:b)
          instructions[0xA9] = Instructions::XorReg8.new(:c)
          instructions[0xAA] = Instructions::XorReg8.new(:d)
          instructions[0xAB] = Instructions::XorReg8.new(:e)
          instructions[0xAC] = Instructions::XorReg8.new(:h)
          instructions[0xAD] = Instructions::XorReg8.new(:l)

          instructions[0xAF] = Instructions::XorReg8.new(:a)

          # Opcodes: 0xB0 - 0xBF

          # Opcodes: 0xC0 - 0xCF
          instructions[0xC3] = Instructions::JpImm16.new

          # Opcodes: 0xD0 - 0xDF
          # Opcodes: 0xE0 - 0xEF
          # Opcodes: 0xF0 - 0xFF

          instructions
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
