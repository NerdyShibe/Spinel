# frozen_string_literal: true

module Spinel
  module Hardware
    class Cpu
      #
      # Describes the High RAM inside the Game Boy SoC chip
      # Because it's in the same chip as the CPU has lower latency
      # It is used for faster instructions like the LDH
      #
      # Can be read or written to
      # Has 128 bytes reserved to it between $FF80 and $FFFE
      #
      class Hram
        def initialize
          @bytes = Array.new(128, 0x00)
          @start_offset = 0xFF80
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
          (0xFF80..0xFFFE).cover?(address)
        end
      end
    end
  end
end
