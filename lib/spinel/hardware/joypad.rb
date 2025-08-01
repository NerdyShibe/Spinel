# frozen_string_literal: true

module Spinel
  module Hardware
    # Joypad Port
    #
    # TODO: Implement Joypad request interrupt
    class Joypad
      attr_accessor :p1

      def initialize(interrupts)
        @interrupts = interrupts

        @p1 = 0xCF
      end
    end
  end
end
