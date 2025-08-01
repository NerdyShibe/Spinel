# frozen_string_literal: true

module Spinel
  module Hardware
    # Pixel Processing Unit
    #
    class Ppu
      attr_reader :mode

      def initialize(vram)
        @mode = Modes::OAM_SCAN
        @registers = Registers.new
        @oam = Ram.new(bytes: 160, start_offset: 0xFE00)
        @vram = vram
      end

      # Returns garbage data (0xFF) if in OAM Scan or Drawing modes
      #
      def read_oam(address)
        return 0xFF if [Modes::OAM_SCAN, Modes::DRAWING].include?(@mode)

        @oam.read_byte(address)
      end

      # Direct write is not allowed in OAM Scan or Drawing modes
      #
      def write_oam(address)
        return if [Modes::OAM_SCAN, Modes::DRAWING].include?(@mode)

        @oam.write_byte(address)
      end

      def read_registers(address)
        case address
        when 0xFF40 then @registers.lcdc
        when 0xFF41 then @registers.stat
        when 0xFF42 then @registers.scy
        when 0xFF43 then @registers.scx
        when 0xFF44 then @registers.ly
        when 0xFF45 then @registers.lyc
        when 0xFF47 then @registers.bgp
        when 0xFF48 then @registers.obp0
        when 0xFF49 then @registers.obp1
        when 0xFF4A then @registers.wy
        when 0xFF4B then @registers.wx
        end
      end

      def write_registers(address, value)
        case address
        when 0xFF40 then @registers.lcdc = value
        when 0xFF41 then @registers.stat = value
        when 0xFF42 then @registers.scy = value
        when 0xFF43 then @registers.scx = value
        when 0xFF44 then @registers.ly = 0
        when 0xFF45 then @registers.lyc = value
        when 0xFF47 then @registers.bgp = value
        when 0xFF48 then @registers.obp0 = value
        when 0xFF49 then @registers.obp1 = value
        when 0xFF4A then @registers.wy = value
        when 0xFF4B then @registers.wx = value
        end
      end

      private

      # Renders a single frame to the screen.
      def render_frame; end

      # Iterates through OAM and draws all 40 possible sprites.
      def draw_oam_sprites; end

      # Draws a single 8x8 tile to the pixel buffer.
      def draw_tile; end

      # Helper to set a pixel in our 1D pixel buffer.
      def set_pixel; end
    end
  end
end
