# frozen_string_literal: true

module Spinel
  module Cpu
    #
    # Will hold the state of the CPU registers
    # A => The Accumulator register
    # F => Flags register
    class Registers
      attr_accessor :a, :f, :b, :c, :d, :e, :h, :l, :sp, :pc

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
        @pc = 0x0100
      end

      # CPU uses a combination of the 8-bit registers
      # to create 16-bit registers
      #
      def af
        @af = (@a << 8) | @f
      end

      def af=(value)
        @a = value >> 8
        @f = (value & 0xFF) & 0xF0 # Lower 4 bits are always 0
      end

      def bc
        @bc = (@b << 8) | @c
      end

      def bc=(value)
        @b = value >> 8
        @c = value & 0xFF
      end

      def de
        @de = (@d << 8) | @e
      end

      def de=(value)
        @d = value >> 8
        @e = value & 0xFF
      end

      def hl
        @hl = (@h << 8) | @l
      end

      def hl=(value)
        @h = value >> 8
        @l = value & 0xFF
      end

      # Zero Flag
      # Bit7 of the Flags register (@f)
      # Determines if the result of the last
      # arithmetic operation was zero
      #
      def z_flag
        (@f & 0b10000000) >> 7
      end

      def z_flag=(bit_value)
        if (bit_value & 1) == 1
          @f |= 0b10000000
        else
          @f &= 0b01111111
        end
      end

      # Subtraction Flag
      # Bit6 of the Flags register (@f)
      # Determines if the last operation
      # was a subtraction
      #
      def n_flag
        (@f & 0b01000000) >> 6
      end

      def n_flag=(bit_value)
        if (bit_value & 1) == 1
          @f |= 0b01000000
        else
          @f &= 0b10111111
        end
      end

      # Half Carry Flag
      # Bit5 of the Flags register (@f)
      # ??
      #
      def h_flag
        (@f & 0b00100000) >> 5
      end

      def h_flag=(bit_value)
        if (bit_value & 1) == 1
          @f |= 0b00100000
        else
          @f &= 0b11011111
        end
      end

      # Carry Flag
      # Bit4 of the Flags register (@f)
      #
      # Value is set to 1 on the following scenarios:
      # When the result of an 8-bit addition is higher than $FF.
      # When the result of a 16-bit addition is higher than $FFFF.
      # When the result of a subtraction or comparison is lower than zero.
      # When a rotate/shift operation shifts out a “1” bit.
      #
      def c_flag
        (@f & 0b00010000) >> 4
      end

      def c_flag=(bit_value)
        if (bit_value & 1) == 1
          @f |= 0b00010000
        else
          @f &= 0b11101111
        end
      end

      def set_flags(z:, n:, h:, c:) # rubocop:disable Naming/MethodParameterName
        self.z_flag = z
        self.n_flag = n
        self.h_flag = h
        self.c_flag = c
      end
    end
  end
end
