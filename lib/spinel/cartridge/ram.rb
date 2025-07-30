# frozen_string_literal: true

module Spinel
  class Cartridge
    # External RAM inside the Cartridge
    #
    # Mapped to the address range: $A000 - $BFFF
    # Holds 8192 bytes = 8 KiB of memory
    #
    class Ram
      def initialize
        @data = Array.new(8192, 0x00)
        @start_offset = 0xA000
      end

      def read_byte(address)
        @data[address - @start_offset]
      end

      def write_byte(address, byte)
        @data[address - @start_offset] = byte & 0xFF
      end
    end
  end
end
