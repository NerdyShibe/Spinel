# frozen_string_literal: true

module Spinel
  module Hardware
    #
    # This Class represents the 16-bit address bus of the Game Boy
    # Which is used to map the address values for the ROM, RAM, and I/O.
    #
    # Memory Map
    # ===============================================================================================
    # Start	End	  Description	                    Notes
    # 0000  3FFF	16 KiB ROM bank 00	            From cartridge, usually a fixed bank
    # 4000	7FFF	16 KiB ROM Bank 01–NN	          From cartridge, switchable bank via mapper (if any)
    # 8000	9FFF	8 KiB Video RAM (VRAM)	        In CGB mode, switchable bank 0/1
    # A000	BFFF	8 KiB External RAM	            From cartridge, switchable bank if any
    # C000	CFFF	4 KiB Work RAM (WRAM)
    # D000	DFFF	4 KiB Work RAM (WRAM)	          In CGB mode, switchable bank 1–7
    # E000	FDFF	Echo RAM (mirror of C000–DDFF)	Nintendo says use of this area is prohibited.
    # FE00	FE9F	Object attribute memory (OAM)
    # FEA0	FEFF	Not Usable	                    Nintendo says use of this area is prohibited.
    # FF00	FF7F	I/O Registers
    # FF80	FFFE	High RAM (HRAM)
    # FFFF	FFFF	Interrupt Enable register (IE)
    # ===============================================================================================
    #
    class Bus
      def initialize(cartridge, ppu, vram, wram, hram, interrupts, serial, timer, joypad) # rubocop:disable Metrics/ParameterLists
        @cartridge = cartridge
        @ppu = ppu
        @vram = vram
        @wram = wram
        @hram = hram
        @interrupts = interrupts
        @serial = serial
        @timer = timer
        @joypad = joypad
      end

      # Delegates which component should be involved
      # depending on the address range
      #
      # @param address [Integer] => 16-bit value
      # @return [Integer] => 8-bit value
      #
      def read_byte(address)
        case address
        when 0x0000..0x3FFF then @cartridge.rom_read(address)
        when 0x4000..0x7FFF then @cartridge.rom_read(address)
        when 0x8000..0x9FFF then @vram.read_byte(address)
        when 0xA000..0xBFFF then @cartridge.ram_read(address)
        when 0xC000..0xDFFF then @wram.read_byte(address)
        when 0xE000..0xFDFF then @wram.read_byte(address - 0x2000)
        when 0xFE00..0xFE9F then @ppu.read_oam(address)
        when 0xFEA0..0xFEFF then 0xFF
        when 0xFF00..0xFF7F
          case address
          when 0xFF00 then @joypad.read_byte(address)
          when 0xFF01..0xFF02 then @serial.read_byte(address)
          when 0xFF04..0xFF07 then @timer.read_byte(address)
          when 0xFF0F then @interrupts.read_byte(address)
          when 0xFF40..0xFF4B then @ppu.read_registers(address)
          else 0xFF
          end
        when 0xFF80..0xFFFE then @hram.read_byte(address)
        when 0xFFFF then @interrupts.read_byte(address)
        else
          raise StandardError, "Memory out of bounds at: #{format('%04X', address)}"
        end
      end

      # Delegates which component should write the data
      # depending on the address range
      #
      # @param address [Integer] => 16-bit value
      # @param value [Integer] => 8-bit value
      #
      def write_byte(address, value)
        case address
        when 0x0000..0x3FFF then @cartridge.rom_write(address, value)
        when 0x4000..0x7FFF then @cartridge.rom_write(address, value)
        when 0x8000..0x9FFF then @vram.write_byte(address, value)
        when 0xA000..0xBFFF then @cartridge.ram_write(address, value)
        when 0xC000..0xDFFF then @wram.write_byte(address, value)
        when 0xE000..0xFDFF then @wram.write_byte(address, value - 0x2000)
        when 0xFE00..0xFE9F then @ppu.write_oam(address, value)
        when 0xFEA0..0xFEFF then 0xFF
        when 0xFF00..0xFF7F
          case address
          when 0xFF00 then @joypad.write_byte(address, value)
          when 0xFF01..0xFF02 then @serial.write_byte(address, value)
          when 0xFF04..0xFF07 then @timer.write_byte(address, value)
          when 0xFF0F then @interrupts.write_byte(address, value)
          when 0xFF40..0xFF4B then @ppu.write_registers(address, value)
          else 0xFF
          end
        when 0xFF80..0xFFFE then @hram.write_byte(address, value)
        when 0xFFFF then @interrupts.write_byte(address, value)
        else
          raise StandardError, "Memory out of bounds at: #{format('%04X', address)}"
        end
      end
    end
  end
end
