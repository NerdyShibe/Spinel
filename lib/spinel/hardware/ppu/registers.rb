# frozen_string_literal: true

module Spinel
  module Hardware
    class Ppu
      # PPU Registers
      #
      # $FF40 => LCDC: LCD Control
      # $FF41 => STAT: LCD Status
      # $FF42 - $FF43 => SCY, SCX: Background viewport Y and X positions
      # $FF44 => LY: LCD Y Coordinate (Read-only)
      # $FF45 => LYC: LY Compare
      # $FF46 => DMA: OAM DMA source address & start
      # $FF47 => BGP: BG Palette Data (Non-CGB Mode only)
      # $FF48 - $FF49 => OBP0, OBP1: Object palette 0, 1 data (Non-CGB Mode only)
      # $FF4A - $FF4B => WY, WX: Window Y position, X position plus 7
      #
      class Registers
        attr_accessor :lcdc, :scy, :scx, :lyc, :bgp, :obp0, :obp1, :wy, :wx
        attr_reader :stat, :ly

        def initialize
          @lcdc = 0x91
          @stat = 0x85
          @scy  = 0x00
          @scx  = 0x00
          @ly   = 0x00
          @lyc  = 0x00
          @bgp  = 0xFC
          @obp0 = 0xFF
          @obp1 = 0xFF
          @wy   = 0x00
          @wx   = 0x00
        end

        # Only bits 3-6 are writable by the CPU
        #
        # | 7 | 6* | 5* | 4* | 3* | 2 | 1 | 0 |
        #
        def stat=(value)
          @stat = (value & 0b01111000) | (@stat & 0b10000111)
        end

        def ly=(value)
          @ly = value & 0x99
        end
      end
    end
  end
end
