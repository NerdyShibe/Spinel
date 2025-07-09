# frozen_string_literal: true

module Spinel
  module Types
    #
    # This defines a new Numeric type
    # to be used across the emulator.
    # Should be used to represent a
    # 16-bit integer value
    class Word < Numeric
      attr_reader :value

      def initialize(value) # rubocop:disable Lint/MissingSuper
        @value = value & 0xFFFF
      end

      def in_decimal
        @value.to_s
      end

      def in_hexa
        @value.to_s(16).upcase.rjust(4, '0')
      end

      def in_binary
        @value.to_s(2).rjust(16, '0')
      end
    end
  end
end
