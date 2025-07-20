# frozen_string_literal: true

module Spinel
  module Cartridge
    # TODO: Implement the ROM Bank switching
    # Needs to hold all data for the game
    # Needs to define which bank is loaded into Bank N
    # Needs to switch banks
    class Base
      def initialize(_rom_file)
        @default_rom_bank = []
        @switchable_rom_bank = []
      end
    end
  end
end
