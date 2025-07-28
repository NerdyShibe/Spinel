# frozen_string_literal: true

module Spinel
  # Game Pak
  #
  # Memory map
  # $0000 - $3FFF	16 KiB ROM bank 00
  # $4000 - $7FFF	16 KiB ROM Bank 01–NN
  #
  class Cartridge
    def initialize(rom_file)
      @rom = Rom.new(rom_file)
      @ram = Ram.new
    end

    def rom_read(address)
      @rom.read_byte(address)
    end

    def rom_write(address, value)
      @rom.write_byte(address, value)
    end

    def ram_read(address)
      @ram.read_byte(address)
    end

    def ram_write(address, value)
      @ram.write_byte(address, value)
    end
  end
end
