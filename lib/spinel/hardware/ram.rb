# frozen_string_literal: true

module Spinel
  module Hardware
    #
    # Describes a general purpose RAM that will be used
    # as a factory to create the specific ones
    #
    # WRAM => Work RAM
    # VRAM => Video RAM
    # HRAM => High RAM
    #
    class Ram
      def initialize(bytes:, start_offset:)
        @bytes = bytes
        @start_offset = start_offset

        @data = Array.new(bytes, 0x00)
      end

      def read_byte(address)
        @data[address - @start_offset]
      end

      def write_byte(address, value)
        @data[address - @start_offset] = value & 0xFF
      end
    end
  end
end
