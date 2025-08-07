# frozen_string_literal: true

module Spinel
  module Hardware
    class Timer
      # Will hold the state of the Timer registers
      #
      # $FF04 DIV  => Divider Register
      # $FF05 TIMA => Timer Counter
      # $FF06 TMA  => Timer Modulo
      # $FF07 TAC  => Timer Control
      #
      class Registers
        attr_reader :div, :tima, :tma

        def initialize
          @div  = 0xABCC
          @tima = 0x00
          @tma  = 0x00
          @tac  = 0x00
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

        # TAC register only uses Bit0 - Bit2
        # Any write to other bits can be ignored
        #
        def tac=(value)
          @tac = value & 0b00000111
        end

        # Unused bits are pulled high (1)
        #
        def tac
          @tac | 0b11111000
        end

        # Enable switch is on Bit2
        # Determines if TIMA increments at all
        #
        def tac_enable
          @tac[2]
        end

        # Clock select is on Bits 1-0
        # Determines the frequency in which TIMA increments
        #
        # 0b00 => TIMA increments every 256 M-cycles
        # 0b01 => TIMA increments every 4 M-cycles
        # 0b10 => TIMA increments every 16 M-cycles
        # 0b11 => TIMA increments every 64 M-cycles
        #
        def tac_clock_select
          @tac & 0b11
        end
      end
    end
  end
end
