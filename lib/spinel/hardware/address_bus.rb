# frozen_string_literal: true

module Spinel
  module Hardware
    # This Class represents the 16-bit address bus of the Game Boy
    # Which is used to map the address values for the ROM, RAM, and I/O.
    #
    class AddressBus
      IN_ROM_BANK_0_RANGE   = (0x0000..0x3FFF)
      IN_ROM_BANK_N_RANGE   = (0x4000..0x7FFF)
      IN_VIDEO_RAM_RANGE    = (0x8000..0x9FFF)
      IN_EXTERNAL_RAM_RANGE = (0xA000..0xBFFF)
      IN_WORK_RAM_RANGE     = (0xC000..0xDFFF)
      IN_ECHO_RAM_RANGE     = (0xE000..0xFDFF)
      IN_OAM_RANGE          = (0xFE00..0xFE9F)
      IN_NOT_USABLE_RANGE   = (0xFEA0..0xFEFF)
      IN_IO_REGISTERS_RANGE = (0xFF00..0xFF7F)
      IN_HIGH_RAM_RANGE     = (0xFF80..0xFFFE)

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
        case address
        when IN_ROM_BANK_0_RANGE   then @cartridge.rom_read(address)
        when IN_ROM_BANK_N_RANGE   then @cartridge.rom_read(address)
        when IN_VIDEO_RAM_RANGE    then @vram.read_byte(address)
        when IN_EXTERNAL_RAM_RANGE then @cartridge.ram_read(address)
        when IN_WORK_RAM_RANGE     then @wram.read_byte(address)
        when IN_ECHO_RAM_RANGE     then @wram.read_byte(address - 0x2000)
        when IN_OAM_RANGE          then @ppu.read_oam(address)
        when IN_NOT_USABLE_RANGE   then 0xFF
        when IN_IO_REGISTERS_RANGE
          case address
          when 0xFF00         then @joypad.p1
          when 0xFF01         then @serial_port.sb
          when 0xFF02         then @serial_port.sc
          when 0xFF04..0xFF07 then @timer.read_registers(address)
          when 0xFF0F         then @interrupts.if
          when 0xFF40..0xFF4B then @ppu.read_registers(address)
          else 0xFF
          end
        when IN_HIGH_RAM_RANGE then @hram.read_byte(address)
        when 0xFFFF then @interrupts.ie
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
          when 0xFF00         then @joypad.p1 = value
          when 0xFF01         then @serial_port.sb = value
          when 0xFF02         then @serial_port.sc = value
          when 0xFF04..0xFF07 then @timer.write_registers(address, value)
          when 0xFF0F         then @interrupts.if = value
          when 0xFF40..0xFF4B then @ppu.write_registers(address, value)
          else 0xFF
          end
        when 0xFF80..0xFFFE then @hram.write_byte(address, value)
        when 0xFFFF then @interrupts.ie = value
        else
          raise StandardError, "Memory out of bounds at: #{format('%04X', address)}"
        end
      end
    end
  end
end
