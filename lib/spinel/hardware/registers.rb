# frozen_string_literal: true

module Spinel
  module Hardware
    #
    # Will hold the state of the CPU registers
    # A => The Accumulator register
    # F => Flags register
    class Registers
      attr_accessor :a, :f, :b, :c, :d, :e, :h, :l, :sp, :pc
      attr_writer :zf, :sf, :hcf, :cf, :af, :bc, :de, :hl

      def initialize
        @a = 0x00
        @f = 0x00
        @b = 0x00
        @c = 0x00
        @d = 0x00
        @e = 0x00
        @h = 0x00
        @l = 0x00

        @sp = 0x0000
        @pc = 0x0000
      end

      #
      # Zero Flag
      # Checks if the Bit7 of the Flags register is set
      def zf
        (@f & 0b10000000) != 0
      end

      #
      # Subtraction Flag
      # Checks if the Bit6 of the Flags register is set
      def sf
        (@f & 0b01000000) != 0
      end

      #
      # Half Carry Flag
      # Checks if the Bit5 of the Flags register is set
      def hcf
        (@f & 0b00100000) != 0
      end

      #
      # Carry Flag
      # Checks if the Bit4 of the Flags register is set
      def cf
        (@f & 0b00010000) != 0
      end

      #
      # Accumulator + Flags registers
      def af
        @af = (@a << 8) + @f
      end

      def bc
        @bc = (@b << 8) + @c
      end

      def de
        @de = (@d << 8) + @e
      end

      def hl
        @hl = (@h << 8) + @l
      end
    end
  end
end
