# frozen_string_literal: true

module Spinel
  module Hardware
    # Serial Port
    #
    class Joypad
      def initialize
        @p1_joypad = 0xCF
      end

      def read_byte(address)
        case address
        when 0xFF00 then @p1_joypad
        end
      end

      def write_byte(address, value)
        case address
        when 0xFF00 then @p1_joypad = value
        end
      end
    end
  end
end
