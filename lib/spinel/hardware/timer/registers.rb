# frozen_string_literal: true

module Spinel
  module Hardware
    class Timer
      # Timer Registers
      #
      # $FF04 => DIV: Divider register
      # $FF05 => TIMA: Timer counter
      # $FF06 => TMA: Timer modulo
      # $FF07 => TAC: Timer control
      #
      class Registers
        attr_reader :div, :tima, :tma, :tac

        # Maps TAC clock select to the bit of the internal DIV
        # counter that TIMA is synchronized to.
        DIV_BIT_SELECTOR = [9, 3, 5, 7].freeze # For 1024, 16, 64, 256 cycles

        def initialize
          @div = 0xABCC
          @tima = 0x00
          @tma = 0x00
          @tac = 0x00
        end

        def div_bit_trigger
          bit_position = DIV_BIT_SELECTOR[tac_clock]

          (@div >> bit_position) & 1
        end

        def div=(value)
          @div = value & 0xFFFF
        end

        def tima=(value)
          @tima = value & 0xFF
        end

        def tma=(value)
          @tma = value & 0xFF
        end

        # Only Bits 3-0 are used
        # The others are 1
        #
        def tac=(value)
          @tac = value & 0b111
        end

        # Bit2 determines if TAC is enabled or not
        #
        def tac_enable
          (@tac >> 2) & 1
        end

        # Bits 1-0 determines the frequency in which TIMA
        # is incremented
        #
        # 00 => Increments every 256 M-cycles = 1024 T-cycles
        # 01 => Increments every 4 M-cycles = 16 T-cycles
        # 10 => Increments every 16 M-cycles = 64 T-cycles
        # 11 => Increments every 64 M-cycles = 256 T-cycles
        #
        def tac_clock
          @tac & 0b11
        end
      end
    end
  end
end
