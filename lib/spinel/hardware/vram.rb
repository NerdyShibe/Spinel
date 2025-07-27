# frozen_string_literal: true

module Spinel
  module Hardware
    #
    # Describes the VRAM chip inside the Game Boy
    # Can be read or written to
    # Has a total of 8 KiB addressable values between
    # $8000 - $9FFF
    #
    class Vram
      def initialize
        @bytes = Array.new(8192, 0x00) # 8 KiB
        @start_offset = 0x8000
      end

      def read_byte(address)
        raise('Address is out of bounds') unless valid?(address)

        @bytes[address - @start_offset]
      end

      def write_byte(address, byte)
        raise('Address is out of bounds') unless valid?(address)

        @bytes[address - @start_offset] = byte & 0xFF
      end

      private

      def valid?(address)
        (0x8000..0x9FFF).cover?(address)
      end
    end
  end
end
