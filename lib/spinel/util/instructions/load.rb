# frozen_string_literal: true

module Spinel
  module Util
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

          @mnemonic = metadata[:mnemonic]
          @bytes = metadata[:bytes]
          @cycles = metadata[:cycles]
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
        # M-cycle 1 => Fetches opcode and loads the value
        #
        def ld_reg8_reg8(cpu)
          source_value = cpu.registers.send(@source_register)
          cpu.registers.send("#{@target_register}=", source_value)
        end

        # Fetches the byte that HL is pointing to in memory
        # stores the value into a given 8-bit register
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Fetches value at (HL) and loads into a 8-bit register
        #
        def ld_reg8_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          cpu.registers.send("#{@target_register}=", value_at_mem_hl)
        end

        # Stores the value of a given 8-bit register
        # into the address pointed to by HL register
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Writes the value of a 8-bit register into (HL)
        #
        def ld_mem_hl_reg8(cpu)
          source_value = cpu.registers.send(@source_register)
          cpu.bus_write(cpu.registers.hl, source_value)
        end

        # Fetches the next immediate byte in memory
        # Stores the value into a given 8-bit register
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Fetches next immediate byte and loads into a 8-bit register
        #
        def ld_reg8_imm8(cpu)
          immediate_byte = cpu.fetch_next_byte
          cpu.registers.send("#{@target_register}=", immediate_byte)
        end

        # Fetches the next immediate byte in memory
        # Stores the value into the address pointed to by HL in memory
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Fetches next immediate byte
        # M-cycle 3 => Writes the value in (HL)
        #
        def ld_mem_hl_imm8(cpu)
          immediate_byte = cpu.fetch_next_byte
          cpu.bus_write(cpu.registers.hl, immediate_byte)
        end

        # Loads the value from HL register into the Stack Pointer
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Takes a cycle to perform the 16-bit load
        #
        def ld_sp_hl(cpu)
          source_value = cpu.registers.hl
          cpu.load16(:sp, source_value)
        end

        # Fetches the 2 immediate bytes from memory
        # Assembles the address from the 2 bytes (little endian)
        # Writes the lower byte of SP into the address
        # Writes the higher byte of SP into the address + 1
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Fetches the next immediate byte (low byte)
        # M-cycle 3 => Fetches the next immediate byte (high byte)
        # M-cycle 4 => Assembles a 16-bit address and stores the low byte of SP
        # M-cycle 5 => Stores the high byte of SP into (address + 1)
        #
        def ld_mem_imm16_sp(cpu)
          lsb = cpu.fetch_next_byte
          msb = cpu.fetch_next_byte
          address = (msb << 8) | lsb

          sp = cpu.registers.sp
          cpu.bus_write(address, sp & 0xFF)
          cpu.bus_write(address + 1, (sp >> 8) & 0xFF)
        end

        # Fetches an immediate byte from memory
        # Converts the byte into a signed value
        # Adds the signed value into SP
        # Calculate the changes in the registers flags
        # Loads the result into HL register pair
        #
        # This is the only Load instruction that affects register flags
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Fetches the next immediate byte (unsigned)
        # M-cycle 3 => Signs the byte, adds it to SP and loads into HL
        #
        def ld_hl_sp_plus_sig8(cpu)
          unsigned_byte = cpu.fetch_next_byte
          sp = cpu.registers.sp
          signed_byte = cpu.sign_value(unsigned_byte)
          result = sp + signed_byte

          cpu.registers.z_flag = false
          cpu.registers.n_flag = false
          cpu.registers.h_flag = (sp & 0x0F) + (unsigned_byte & 0x0F) > 0x0F
          cpu.registers.c_flag = (sp & 0xFF) + unsigned_byte > 0xFF

          cpu.registers.hl = result
        end

        # Fetches the next 2 immediate bytes in memory
        # First byte is the lowest significant and the second is the most significant
        # Stores the value into a given 16-bit special register
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Fetches the next immediate byte (less significant)
        # M-cycle 3 => Fetches the next immediate byte (most significant) and loads the value
        #
        def ld_reg16_imm16(cpu)
          lsb = cpu.fetch_next_byte
          msb = cpu.fetch_next_byte
          immediate_word = (msb << 8) | lsb

          cpu.registers.send("#{@target_register}=", immediate_word)
        end

        # Stores the value of A into the address pointed to by a 16-bit register
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Writes the A value into the address
        #
        def ld_mem_reg16_a(cpu)
          address = cpu.registers.send(@target_register)
          cpu.bus_write(address, cpu.registers.a)
        end

        # Gets the value in memory pointed to by a 16-bit register and stores in A
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Reads the value at the memory location and stores in A
        #
        def ld_a_mem_reg16(cpu)
          address = cpu.registers.send(@source_register)
          fetched_byte = cpu.bus_read(address)
          cpu.registers.a = fetched_byte
        end

        # Fetches 2 immediate bytes, assembles a 16-bit address
        # Stores the value of A into that address
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Fetches next immediate byte (less significant)
        # M-cycle 3 => Fetches next immediate byte (most significant)
        # M-cycle 4 => Assembles 16-bit address and writes the value
        #
        def ld_mem_imm16_a(cpu)
          lsb = cpu.fetch_next_byte
          msb = cpu.fetch_next_byte
          address = (msb << 8) | lsb

          cpu.bus_write(address, cpu.registers.a)
        end

        # Fetches 2 immediate bytes, assemble a 16-bit address
        # Reads the value from that address and loads into A
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Fetches next immediate byte (less significant)
        # M-cycle 3 => Fetches next immediate byte (most significant)
        # M-cycle 4 => Reads value from memory and loads into A
        #
        def ld_a_mem_imm16(cpu)
          lsb = cpu.fetch_next_byte
          msb = cpu.fetch_next_byte
          address = (msb << 8) | lsb

          fetched_byte = cpu.bus_read(address)
          cpu.registers.a = fetched_byte
        end

        # Stores the value of A at (HL) and increments HL
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Writes the A value into HL address
        #
        def ldi_mem_hl_a(cpu)
          address = cpu.registers.hl
          cpu.bus_write(address, cpu.registers.a)
          cpu.registers.hl += 1
        end

        # Fetches byte at (HL) and stores into A
        # Also increments HL after
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Reads value at (HL) and loads into A
        #
        def ldi_a_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          cpu.registers.a = value_at_mem_hl
          cpu.registers.hl += 1
        end

        # Stores the value of A at (HL) and decrements HL
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Writes the A value into HL address
        #
        def ldd_mem_hl_a(cpu)
          address = cpu.registers.hl
          cpu.bus_write(address, cpu.registers.a)
          cpu.registers.hl -= 1
        end

        # Fetches byte at (HL) and stores into A
        # Also decrements HL after
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Reads value at (HL) and loads into A
        #
        def ldd_a_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          cpu.registers.a = value_at_mem_hl
          cpu.registers.hl -= 1
        end

        # Fetches next immediate byte, adds value into $FF00
        # Stores the value of A into that address
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Fetches next immediate byte and adds to $FF00
        # M-cycle 3 => Writes the A value into the address
        #
        def ldh_mem_imm8_a(cpu)
          unsigned_byte = cpu.fetch_next_byte
          high_ram_address = 0xFF00 + unsigned_byte
          cpu.bus_write(high_ram_address, cpu.registers.a)
        end

        # Fetches next immediate byte, adds value into $FF00
        # Stores the value of A into that address
        #
        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Fetches next immediate byte and adds to $FF00
        # M-cycle 3 => Reads the value from the address and loads into A
        #
        def ldh_a_mem_imm8(cpu)
          unsigned_byte = cpu.fetch_next_byte
          high_ram_address = 0xFF00 + unsigned_byte

          fetched_byte = cpu.bus_read(high_ram_address)
          cpu.registers.a = fetched_byte
        end

        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Writes the A value into the address of ($FF00 + C)
        #
        def ldh_mem_c_a(cpu)
          high_ram_address = 0xFF00 + cpu.registers.c
          cpu.bus_write(high_ram_address, cpu.registers.a)
        end

        # M-cycle 1 => Fetches opcode
        # M-cycle 2 => Reads value from ($FF00 + C) and stores into A
        #
        def ldh_a_mem_c(cpu)
          high_ram_address = 0xFF00 + cpu.registers.c
          fetched_byte = cpu.bus_read(high_ram_address)
          cpu.registers.a = fetched_byte
        end
      end
    end
  end
end
