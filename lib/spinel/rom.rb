# frozen_string_literal: true

module Spinel
  # Represents a Game Boy ROM Cartridge.
  #
  # This class is responsible for loading the ROM data from a given ROM file
  # and providing the Emulator to access it.
  # It is the first step in the emulation process, as the ROM
  # contains the game's code and data that the emulator will execute.
  class Rom
    def initialize(rom_path)
      @rom_data = File.binread(rom_path).bytes
    end

    attr_reader :rom_data

    def nintendo_logo
      logo = rom_data[0x0104..0x0133] || []
      # --- What '%02X' means ---
      # % : Start of a format specifier
      # 0 : Pad with zeros instead of spaces
      # 2 : The total width of the string should be 2 characters
      # X : Format the number as an uppercase hexadecimal value
      logo.map { |decimal| format('%02X', decimal) }.join(' ')
    end

    # 0134-0143 — Title
    # These bytes contain the title of the game in upper case ASCII.
    # If the title is less than 16 characters long, the remaining bytes
    # should be padded with $00s.
    #
    # Parts of this area actually have a different meaning on later cartridges,
    # reducing the actual title size to 15 ($0134–$0142) or 11 ($0134–$013E) characters
    def title
      title = rom_data[0x0134..0x0143] || []
      title.map { |decimal| format('%02X', decimal) }.join(' ')
    end

    def manufacturer_code
      manufacturer_code = rom_data[0x13F..0x0142] || []
      manufacturer_code.map { |decimal| format('%02X', decimal) }.join(' ')
    end

    def cgb_flag
      cgb_flag = rom_data[0x0143] || ''
      format('%02X', cgb_flag)
    end

    def licensee_code
      licensee_code = rom_data[0x0144..0x0145] || []
      ascii_offset = 48
      licensee_code.map { |decimal| (decimal + ascii_offset).chr }.join
    end
  end
end
