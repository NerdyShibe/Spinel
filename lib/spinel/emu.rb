# frozen_string_literal: true

module Spinel
  # This class will describe the Game Boy Emulator
  class Emu
    def initialize(file)
      load_rom(file)
      verify_rom(file)
      print_rom_info
    end

    def run
      # Main core loop
      # Keep track of the registers
      # Initialize PC Register = $0100
      # Load run
      # Loop forever
      # next instruction
      # execute instruction
    end

    private

    # Load the ROM data
    def load_rom(rom_file)
      @rom = Spinel::Rom.new(rom_file)
    end

    # This method checks the file provided to make sure it's a valid ROM
    #
    # @param file [Blob]
    #
    # @return void
    def verify_rom(file)
      puts file.class
      # Implement some logic to make sure
      # the file is in fact a .gb ROM
    end

    def print_rom_info
      puts '--- ROM Information ---'
      puts "Successfully read #{@rom.rom_data.length / 1024} KiB."
      puts "Nintendo Logo: #{@rom.nintendo_logo}"
      puts "Title: #{@rom.title}"
      puts "Manufacturer Code: #{@rom.manufacturer_code}"
      puts "CGB Flag: #{@rom.cgb_flag}"
      puts "Licensee Code: #{@rom.licensee_code}"
    end
  end
end
