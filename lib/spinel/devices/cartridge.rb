# frozen_string_literal: true

module Spinel
  module Devices
    #
    # Will be used to describe the Game Cartridge
    #
    class Cartridge
      def initialize
        # TODO: Implement the ROM Bank switching
        @default_rom_bank = []
        @switchable_rom_bank = []

        # Needs to hold all data for the game
        # Needs to define which bank is loaded into Bank N
        # Needs to switch banks
      end
    end
  end
end
