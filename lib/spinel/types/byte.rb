# frozen_string_literal: true

module Spinel
  module Types
    #
    # This defines a new Numeric type to be used across the emulator.
    # Should be used to represent a 8-bit Integer value
    class Byte < Numeric
      attr_reader :value

      # Generates a new byte object from an Integer value
      # If the value provided is greater than 255, it will wrap
      # around to 0 after the bitwise AND operation
      #
      # @param Integer
      def initialize(value) # rubocop:disable Lint/MissingSuper
        @value = value & 0xFF
      end

      # Returns the byte representation in decimal (base 10)
      #
      # Examples:
      # Spinel::Types::Byte.new(99).in_decimal => '99'
      # Spinel::Types::Byte.new(255).in_decimal => '255'
      # Spinel::Types::Byte.new(256).in_decimal => '0'
      #
      # @returns String
      def in_decimal
        @value.to_s
      end

      # Returns the byte representation in hexadecimal (base 16)
      # The value is padded with 0s to complete the 8-bit notation (if needed)
      #
      # Examples:
      # Spinel::Types::Byte.new(15).in_hexa => '0x0F'
      # Spinel::Types::Byte.new(99).in_hexa => '0x63'
      # Spinel::Types::Byte.new(255).in_hexa => '0xFF'
      # Spinel::Types::Byte.new(256).in_hexa => '0x00'
      #
      # @returns String
      def in_hexa
        "0x#{@value.to_s(16).upcase.rjust(2, '0')}"
      end

      # Returns the byte representation in binary (base 2)
      # Value is padded with 0s to complete the 8-bit notation (if needed)
      #
      # Examples:
      # Spinel::Types::Byte.new(1).in_binary => '0b00000001'
      # Spinel::Types::Byte.new(7).in_binary => '0b00000111'
      # Spinel::Types::Byte.new(255).in_binary => '0b11111111'
      # Spinel::Types::Byte.new(256).in_binary => '0b00000000'
      #
      # @returns String
      def in_binary
        "0b#{@value.to_s(2).rjust(8, '0')}"
      end

      # Bitwise AND operation with 0b00001111
      # Returns the Integer value of the
      # 4 lower bits from the byte instance
      #
      # @returns Integer
      def lower4
        @value & 0x0F
      end

      # Shifts the 4 higher bits to the right
      # And performs a bitwise AND to extract
      # the Integer value of those
      #
      # @returns Integer
      def higher4
        (@value >> 4) & 0x0F
      end

      # Allows adding elements directly
      # to the byte object and returns a
      # new instance of byte
      #
      # @returns Spinel::Types::Byte
      def +(other)
        Byte.new(@value + other)
      end

      # Allows subtracting elements directly
      # from the byte object and returns a
      # new instance of byte
      #
      # @returns Spinel::Types::Byte
      def -(other)
        Byte.new(@value - other)
      end
    end
  end
end
