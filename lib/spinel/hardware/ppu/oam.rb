# frozen_string_literal: true

module Spinel
  module Hardware
    class Ppu
      # $FE00 - $FE9F	Object attribute memory (OAM)
      #
      class Oam
        def initialize(ppu)
          @data = Array.new(160, 0x00)
          @start_offset = 0xFE00
          @ppu = ppu
        end

        # Returns garbage data (0xFF) if in OAM Scan or Drawing modes
        #
        def read_byte(address)
          return 0xFF if [Modes::OAM_SCAN, Modes::DRAWING].include?(@ppu.mode)

          @data[address - @start_offset]
        end

        # Direct write is not allowed in OAM Scan or Drawing modes
        #
        def write_byte(address, byte)
          return if [Modes::OAM_SCAN, Modes::DRAWING].include?(@ppu.mode)

          @data[address - start_offset] = byte
        end
      end
    end
  end
end
