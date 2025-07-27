# frozen_string_literal: true

module Spinel
  module Hardware
    class Interrupts
      #
      # $FF0F => Interrupt Flag Register
      # $FFFF => Interrupt Enable Register
      class Registers
        attr_accessor :if, :ie

        def initialize
          @ie = 0x00
          @if = 0x00
        end
      end
    end
  end
end
