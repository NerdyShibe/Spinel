# frozen_string_literal: true

module Spinel
  module Hardware
    # This Class represents the 16-bit address bus of the Game Boy
    # Which is used to map the address values for the ROM, RAM, and I/O.
    #
    class AddressBus
      def initialize( # rubocop:disable Metrics/ParameterLists
        cartridge,
        ppu,
        vram,
        wram,
        hram,
        interrupts,
        serial_port,
        timer,
        joypad
      )
        @cartridge = cartridge
        @ppu = ppu
        @vram = vram
        @wram = wram
        @hram = hram
        @interrupts = interrupts
        @serial_port = serial_port
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
        if address.between?(0x0000, 0x7FFF)
          @cartridge.rom_read(address)
        elsif address <= 0x9FFF
          @vram.read_byte(address)
        elsif address <= 0xBFFF
          @cartridge.ram_read(address)
        elsif address <= 0xDFFF
          @wram.read_byte(address)
        elsif address <= 0xFDFF
          @wram.read_byte(address - 0x2000)
        elsif address <= 0xFE9F
          @ppu.read_oam(address)
        elsif address <= 0xFEFF
          0xFF
        elsif address <= 0xFF7F
          if address == 0xFF00
            @joypad.p1
          elsif address == 0xFF01
            @serial_port.sb
          elsif address == 0xFF02
            @serial_port.sc
          elsif address <= 0xFF07
            @timer.read_registers(address)
          elsif address == 0xFF0F
            @interrupts.if
          else
            0xFF
          end
        elsif address <= 0xFFFE
          @hram.read_byte(address)
        elsif address == 0xFFFF
          @interrupts.ie
        else
          raise StandardError, "#{address} is out of bounds"
        end
      end

      # Delegates which component should write the data
      # depending on the address range
      #
      # @param address [Integer] => 16-bit value
      # @param value [Integer] => 8-bit value
      #
      def write_byte(address, value)
        if address.between?(0x0000, 0x7FFF)
          @cartridge.rom_write(address, value)
        elsif address <= 0x9FFF
          @vram.write_byte(address, value)
        elsif address <= 0xBFFF
          @cartridge.ram_write(address, value)
        elsif address <= 0xDFFF
          @wram.write_byte(address, value)
        elsif address <= 0xFDFF
          @wram.write_byte(address - 0x2000, value)
        elsif address <= 0xFE9F
          @ppu.write_oam(address, value)
        elsif address <= 0xFEFF
          return
        elsif address <= 0xFF7F
          if address == 0xFF00
            @joypad.p1 = value
          elsif address == 0xFF01
            @serial_port.sb = value
          elsif address == 0xFF02
            @serial_port.sc = value
          elsif address <= 0xFF07
            @timer.write_registers(address, value)
          elsif address == 0xFF0F
            @interrupts.if = value
          end
        elsif address <= 0xFFFE
          @hram.write_byte(address, value)
        elsif address == 0xFFFF
          @interrupts.ie = value
        else
          raise StandardError, "#{address} is out of bounds"
        end
      end
    end
  end
end
