# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to all possible LD instructions
        #
        class Load
          # @param operation [Symbol] Which type of Load operation
          # @param target_register [Symbol] Register to load the value, if any
          # @param source_register [Symbol] Register to get the value from, if any
          #
          def initialize(operation, target_register = nil, source_register = nil)
            @operation = operation
            @target_register = target_register
            @source_register = source_register

            super(
              mnemonic: metadata[:mnemonic],
              bytes: metadata[:bytes],
              cycles: metadata[:cycles]
            )
          end

          def execute(cpu)
            case @operation
            when :ld_reg8_reg8       then ld_reg8_reg8(cpu)
            when :ld_reg8_mem_hl     then ld_reg8_mem_hl(cpu)
            when :ld_mem_hl_reg8     then ld_mem_hl_reg8(cpu)
            when :ld_reg8_imm8       then ld_reg8_imm8(cpu)
            when :ld_mem_hl_imm8     then ld_mem_hl_imm8(cpu)
            when :ld_sp_hl           then ld_sp_hl(cpu)
            when :ld_mem_imm16_sp    then ld_mem_imm16_sp(cpu)
            when :ld_hl_sp_plus_sig8 then ld_hl_sp_plus_sig8(cpu)
            when :ld_reg16_imm16     then ld_reg16_imm16(cpu)
            when :ld_mem_reg16_a     then ld_mem_reg16_a(cpu)
            when :ld_a_mem_reg16     then ld_a_mem_reg16(cpu)
            when :ld_mem_imm16_a     then ld_mem_imm16_a(cpu)
            when :ld_a_mem_imm16     then ld_a_mem_imm16(cpu)
            when :ldi_mem_hl_a       then ldi_mem_hl_a(cpu)
            when :ldi_a_mem_hl       then ldi_a_mem_hl(cpu)
            when :ldd_mem_hl_a       then ldd_mem_hl_a(cpu)
            when :ldd_a_mem_hl       then ldd_a_mem_hl(cpu)
            when :ldh_mem_imm8_a     then ldh_mem_imm8_a(cpu)
            when :ldh_a_mem_imm8     then ldh_a_mem_imm8(cpu)
            when :ldh_mem_c_a        then ldh_mem_c_a(cpu)
            when :ldh_a_mem_c        then ldh_a_mem_c(cpu)
            else
              raise ArgumentError, "Invalid Load operation: #{@operation}."
            end
          end

          private

          def metadata
            case @operation
            when :ld_reg8_reg8
              { mnemonic: "LD #{@target_register.to_s.upcase}, #{@source_register.to_s.upcase}", bytes: 1, cycles: 4 }
            when :ld_reg8_mem_hl
              { mnemonic: "LD #{@target_register.to_s.upcase}, [HL]", bytes: 1, cycles: 8 }
            when :ld_mem_hl_reg8
              { mnemonic: "LD [HL], #{@source_register.to_s.upcase}", bytes: 1, cycles: 8 }
            when :ld_reg8_imm8
              { mnemonic: "LD #{@target_register.to_s.upcase}, imm8", bytes: 2, cycles: 8 }
            when :ld_mem_hl_imm8
              { mnemonic: 'LD [HL], imm8', bytes: 2, cycles: 12 }
            when :ld_sp_hl
              { mnemonic: 'LD SP, HL', bytes: 1, cycles: 8 }
            when :ld_mem_imm16_sp
              { mnemonic: 'LD [imm16], SP', bytes: 3, cycles: 20 }
            when :ld_hl_sp_plus_sig8
              { mnemonic: 'LD HL, SP + sig8', bytes: 2, cycles: 12 }
            when :ld_reg16_imm16
              { mnemonic: "LD #{@target_register.to_s.upcase}, imm16", bytes: 3, cycles: 12 }
            when :ld_mem_reg16_a
              { mnemonic: "LD [#{@target_register.to_s.upcase}], A", bytes: 1, cycles: 8 }
            when :ld_a_mem_reg16
              { mnemonic: "LD A, [#{@source_register.to_s.upcase}]", bytes: 1, cycles: 8 }
            when :ld_mem_imm16_a
              { mnemonic: 'LD [imm16], A', bytes: 3, cycles: 16 }
            when :ld_a_mem_imm16
              { mnemonic: 'LD A, [imm16]', bytes: 3, cycles: 16 }
            when :ldi_mem_hl_a
              { mnemonic: 'LD [HL+], A', bytes: 1, cycles: 8 }
            when :ldi_a_mem_hl
              { mnemonic: 'LD A, [HL+]', bytes: 1, cycles: 8 }
            when :ldd_mem_hl_a
              { mnemonic: 'LD [HL-], A', bytes: 1, cycles: 8 }
            when :ldd_a_mem_hl
              { mnemonic: 'LD A, [HL-]', bytes: 1, cycles: 8 }
            when :ldh_mem_imm8_a
              { mnemonic: 'LD [$FF00+imm8], A', bytes: 2, cycles: 12 }
            when :ldh_a_mem_imm8
              { mnemonic: 'LD A, [$FF00+imm8]', bytes: 2, cycles: 12 }
            when :ldh_mem_c_a
              { mnemonic: 'LD [$FF00+C], A', bytes: 1, cycles: 8 }
            when :ldh_a_mem_c
              { mnemonic: 'LD A, [$FF00+C]', bytes: 1, cycles: 8 }
            end
          end

          # Stores the value of a given 8-bit source register
          # into another given 8-bit target register
          #
          def ld_reg8_reg8(cpu)
            case cpu.ticks
            when 4
              source_value = cpu.registers.send(@source_register)
              puts "Loading #{@source_register.to_s.upcase}: #{format('%02X', source_value)}" \
                   "into: #{@target_register.to_s.upcase}"
              cpu.registers.send("#{@target_register}=", source_value)
            else wait
            end
          end

          # Fetches the byte that HL is pointing to in memory
          # stores the value into a given 8-bit register
          #
          def ld_reg8_mem_hl(cpu)
            case cpu.ticks
            when 5
              address = cpu.registers.hl
              cpu.request_read(address)
            when 8
              value_at_mem_hl = cpu.receive_data
              puts "Loading value at [HL]: #{format('%02X', value_at_mem_hl)}" \
                   "into: #{@target_register.to_s.upcase}"
              cpu.registers.send("#{@target_register}=", value_at_mem_hl)
            else wait
            end
          end

          # Stores the value of a given 8-bit register
          # into the address pointed to by HL register
          #
          def ld_mem_hl_reg8(cpu)
            case cpu.ticks
            when 5 then cpu.request_write(cpu.registers.hl)
            when 8
              source_value = cpu.registers.send(@source_register)
              puts "Loading #{@source_register.to_s.upcase}: #{format('%02X', source_value)} into [HL]"
              cpu.confirm_write(source_value)
            else wait
            end
          end

          # Fetches the next immediate byte in memory
          # Stores the value into a given 8-bit register
          #
          def ld_reg8_imm8(cpu)
            case cpu.ticks
            when 5 then cpu.request_read
            when 8
              immediate_byte = cpu.receive_data
              puts "Loading Immediate Byte: #{format('%02X', immediate_byte)} " \
                   "into #{@target_register.to_s.upcase}"
              cpu.registers.send("#{@target_register}=", immediate_byte)
            else wait
            end
          end

          # Fetches the next immediate byte in memory
          # Stores the value into the address pointed to by HL in memory
          #
          def ld_mem_hl_imm8(cpu)
            case cpu.ticks
            when 5 then cpu.request_read
            when 8 then @immediate_byte = cpu.receive_data
            when 9 then cpu.request_write(cpu.registers.hl)
            when 12
              puts "Loading Immediate Byte: #{format('%02X', @immediate_byte)} into [HL]"
              cpu.confirm_write(@immediate_byte)
            else wait
            end
          end

          # Loads the value from HL register into the Stack Pointer
          #
          def ld_sp_hl(cpu)
            case cpu.ticks
            when 8
              source_value = cpu.registers.hl
              puts "Loading the value from HL: #{format('%04X', source_value)} into SP"
              cpu.registers.sp = source_value
            else wait
            end
          end

          # Fetches the 2 immediate bytes from memory
          # Assembles the address from the 2 bytes (little endian)
          # Writes the lower byte of SP into the address
          # Writes the higher byte of SP into the address + 1
          #
          def ld_mem_imm16_sp(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.pc)
            when 8 then @lsb = cpu.receive_data
            when 9 then cpu.request_read(cpu.registers.pc)
            when 12
              msb = cpu.receive_data
              @address = (msb << 8) | @lsb
            when 13 then cpu.request_write(@address)
            when 16
              lower_sp = cpu.registers.sp & 0xFF
              cpu.confirm_write(lower_sp)
            when 17 then cpu.request_write(@address + 1)
            when 20
              higher_sp = cpu.registers.sp >> 8
              cpu.confirm_write(higher_sp)
            else wait
            end
          end

          # Fetches an immediate byte from memory
          # Converts the byte into a signed value
          # Adds the signed value into SP
          # Calculate the changes in the registers flags
          # Loads the result into HL register pair
          #
          # This is the only Load instruction that affects register flags
          #
          def ld_hl_sp_plus_sig8(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.pc)
            when 8 then @unsigned_byte = cpu.receive_data
            when 12
              sp = cpu.registers.sp

              cpu.registers.z_flag = false
              cpu.registers.n_flag = false
              cpu.registers.h_flag = (sp & 0x0F) + (@unsigned_byte & 0x0F) > 0x0F
              cpu.registers.c_flag = (sp & 0xFF) + @unsigned_byte > 0xFF

              signed_byte = @unsigned_byte >= 128 ? @unsigned_byte - 256 : @unsigned_byte
              cpu.registers.hl = sp + signed_byte
            else wait
            end
          end

          # Fetches the next 2 immediate bytes in memory
          # First byte is the lowest significant and the second is the most significant
          # Stores the value into a given 16-bit special register
          #
          def ld_reg16_imm16(cpu)
            case cpu.ticks
            when 5 then cpu.request_read
            when 8 then @lsb = cpu.receive_data
            when 9 then cpu.request_read
            when 12
              msb = cpu.receive_data
              immediate_word = (msb << 8) | @lsb
              puts "Loading Immediate Word: #{format('%04X', immediate_word)} " \
                   "into #{@target_register.to_s.upcase}"
              cpu.registers.send("#{@target_register}=", immediate_word)
            else wait
            end
          end

          def ld_mem_reg16_a(cpu)
            raise ArgumentError, 'Target register not provided' if @target_register.nil?

            case cpu.ticks
            when 5
              address = cpu.registers.send(@target_register)
              cpu.request_write(address)
            when 8 then cpu.confirm_write(cpu.registers.a)
            else wait
            end
          end

          def ld_a_mem_reg16(cpu)
            raise ArgumentError, 'Source register not provided' if @source_register.nil?

            case cpu.ticks
            when 5
              address = cpu.registers.send(@source_register)
              cpu.request_read(address)
            when 8
              fetched_byte = cpu.receive_data
              cpu.registers.a = fetched_byte
            else wait
            end
          end

          def ld_mem_imm16_a(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.pc)
            when 8 then @lsb = cpu.receive_data
            when 9 then cpu.request_read(cpu.registers.pc)
            when 12 then @msb = cpu.receive_data
            when 13
              imm16_address = (@msb << 8) | @lsb
              cpu.request_write(imm16_address)
            when 16
              cpu.confirm_write(cpu.registers.a)
            else wait
            end
          end

          def ld_a_mem_imm16(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.pc)
            when 8 then @lsb = cpu.receive_data
            when 9 then cpu.request_read(cpu.registers.pc)
            when 12 then @msb = cpu.receive_data
            when 13
              imm16_address = (@msb << 8) | @lsb
              cpu.request_read(imm16_address)
            when 16
              fetched_byte = cpu.receive_data
              cpu.registers.a = fetched_byte
            else wait
            end
          end

          def ldi_mem_hl_a(cpu)
            case cpu.ticks
            when 5 then cpu.request_write(cpu.registers.hl)
            when 8
              cpu.confirm_write(cpu.registers.a)
              cpu.registers.hl += 1
            else wait
            end
          end

          def ldi_a_mem_hl(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.hl)
            when 8
              value_at_mem_hl = cpu.receive_data
              cpu.registers.a = value_at_mem_hl
              cpu.registers.hl += 1
            else wait
            end
          end

          def ldd_mem_hl_a(cpu)
            case cpu.ticks
            when 5 then cpu.request_write(cpu.registers.hl)
            when 8
              cpu.confirm_write(cpu.registers.a)
              cpu.registers.hl -= 1
            else wait
            end
          end

          def ldd_a_mem_hl(cpu)
            case cpu.ticks
            when 5
              address = cpu.registers.hl
              cpu.request_read(address)
            when 8
              value_at_mem_hl = cpu.receive_data
              cpu.registers.a = value_at_mem_hl
              cpu.registers.hl -= 1
            else wait
            end
          end

          def ldh_mem_imm8_a(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.pc)
            when 8 then @unsigned_byte = cpu.receive_data
            when 9
              high_ram_address = 0xFF00 + @unsigned_byte
              cpu.request_write(high_ram_address)
            when 12
              cpu.confirm_write(cpu.registers.a)
            else wait
            end
          end

          def ldh_a_mem_imm8(cpu)
            case cpu.ticks
            when 5 then cpu.request_read(cpu.registers.pc)
            when 8 then @unsigned_byte = cpu.receive_data
            when 9
              high_ram_address = 0xFF00 + @unsigned_byte
              cpu.request_read(high_ram_address)
            when 12
              high_ram_value = cpu.receive_data
              cpu.registers.a = high_ram_value
            else wait
            end
          end

          def ldh_mem_c_a(cpu)
            case cpu.ticks
            when 5
              high_ram_address = 0xFF00 + cpu.registers.c
              cpu.request_write(high_ram_address)
            when 8
              cpu.confirm_write(cpu.registers.a)
            else wait
            end
          end

          def ldh_a_mem_c(cpu)
            case cpu.ticks
            when 5
              high_ram_address = 0xFF00 + cpu.registers.c
              cpu.request_read(high_ram_address)
            when 8
              high_ram_value = cpu.receive_data
              cpu.registers.a = high_ram_value
            else wait
            end
          end
        end
      end
    end
  end
end
