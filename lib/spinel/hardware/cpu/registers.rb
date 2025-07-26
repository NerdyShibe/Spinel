# rubocop:disable Metrics/ClassLength
# frozen_string_literal: true

module Spinel
  module Hardware
    class Cpu
      # Will hold the state of the CPU registers
      #
      # 8-bit registers => A, F, B, C, D, E, H, L
      # 16-bit registers => SP, PC
      # 16-bit register pairs => AF, BC, DE, HL
      #
      class Registers
        attr_reader :a, :f, :b, :c, :d, :e, :h, :l, :sp, :pc

        def initialize
          @a = 0x01
          @f = 0xB0
          @b = 0x00
          @c = 0x13
          @d = 0x00
          @e = 0xD8
          @h = 0x01
          @l = 0x4D

          @sp = 0xFFFE
          @pc = 0x0100
        end

        def a=(value)
          @a = value & 0xFF
        end

        def b=(value)
          @b = value & 0xFF
        end

        def c=(value)
          @c = value & 0xFF
        end

        def d=(value)
          @d = value & 0xFF
        end

        def e=(value)
          @e = value & 0xFF
        end

        def h=(value)
          @h = value & 0xFF
        end

        def l=(value)
          @l = value & 0xFF
        end

        def af
          (@a << 8) | @f
        end

        def af=(value)
          @a = (value >> 8) & 0xFF
          @f = value & 0xF0 # Lower 4 bits are always 0
        end

        def bc
          (@b << 8) | @c
        end

        def bc=(value)
          @b = (value >> 8) & 0xFF
          @c = value & 0xFF
        end

        def de
          (@d << 8) | @e
        end

        def de=(value)
          @d = (value >> 8) & 0xFF
          @e = value & 0xFF
        end

        def hl
          (@h << 8) | @l
        end

        def hl=(value)
          @h = (value >> 8) & 0xFF
          @l = value & 0xFF
        end

        def sp=(value)
          @sp = value & 0xFFFF
        end

        def pc=(value)
          @pc = value & 0xFFFF
        end

        # Zero Flag => Bit7 of the Flags register (@f)
        # Needs to be set if the result of the last operation was zero
        #
        def z_flag
          @f[7]
        end

        def z_flag=(value)
          set_bit(7, value)
        end

        # Subtraction Flag => Bit6 of the Flags register (@f)
        # Needs to be set if the last operation was a subtraction
        #
        def n_flag
          @f[6]
        end

        def n_flag=(value)
          set_bit(6, value)
        end

        # Half Carry Flag => Bit5 of the Flags register (@f)
        # Needs to be set if the last operation resulted in a half carry
        #
        def h_flag
          @f[5]
        end

        def h_flag=(value)
          set_bit(5, value)
        end

        # Carry Flag => Bit4 of the Flags register (@f)
        #
        # Value is set to 1 on the following scenarios:
        # When the result of an 8-bit addition is higher than $FF.
        # When the result of a 16-bit addition is higher than $FFFF.
        # When the result of a subtraction or comparison is lower than zero.
        # When a rotate/shift operation shifts out a “1” bit.
        #
        def c_flag
          @f[4]
        end

        def c_flag=(value)
          set_bit(4, value)
        end

        def update_flags(z:, n:, h:, c:) # rubocop:disable Naming/MethodParameterName
          self.z_flag = z unless z.nil?
          self.n_flag = n unless n.nil?
          self.h_flag = h unless h.nil?
          self.c_flag = c unless c.nil?
        end

        private

        def set_bit(position, value)
          mask = 1 << position

          if value
            @f |= mask
          else
            @f &= ~mask
          end
        end
      end
    end
  end
end

# rubocop:enable Metrics/ClassLength
