# frozen_string_literal: true

module Spinel
  module Hardware
    class Interrupts
      #
      # $FF0F => Interrupt Flag Register
      # $FFFF => Interrupt Enable Register
      class Registers
        attr_reader :ie, :if

        def initialize
          @ie = 0x00
          @if = 0xE0
        end

        def ie=(value)
          @if = value | 0b11100000
        end

        def if=(value)
          @if = value | 0b11100000
        end
      end
    end
  end
end
