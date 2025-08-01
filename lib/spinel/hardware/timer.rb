# frozen_string_literal: true

module Spinel
  module Hardware
    # Game Boy Timer
    #
    # Hardware Registers
    # $FF03: Divider (DIV)
    # $FF03: TIMA
    # $FF03: TMA
    # $FF03: TAC
    #
    class Timer
      CLOCK_00_TRIGGER_BIT = 9
      CLOCK_01_TRIGGER_BIT = 3
      CLOCK_10_TRIGGER_BIT = 5
      CLOCK_11_TRIGGER_BIT = 7

      def initialize(interrupts)
        @interrupts = interrupts

        @div = 0xABCC
        @tima = 0x00
        @tma = 0x00
        @tac = 0x00

        @previous_div = nil
        @previous_tima = nil
        @previous_tac = nil

        @tima_overflowed = false
        @tima_reload_delay = 4
      end

      def tick
        if @tima_overflowed
          @tima_reload_delay -= 1

          if @tima_reload_delay.zero?
            @tima = @tma
            request_interrupt
            @tima_overflowed = false
          end
        end

        @div = (@div + 1) & 0xFFFF

        if timer_enabled? && div_falling_edge?
          @tima = (@tima + 1) & 0xFF

          if tima_overflowed?
            @tima_overflowed = true
            @tima_reload_delay = 4
          end
        end
      end

      # Only the Timer has access to the full 16-bit value
      # When something tries to read the value it only gets the high byte
      #
      def div
        @div >> 8
      end

      def read_registers(address)
        case address
        when 0xFF04 then div
        when 0xFF05 then @tima
        when 0xFF06 then @tma
        when 0xFF07 then @tac
        end
      end

      # Writing to DIV resets the value to 0
      #
      def write_registers(address, value)
        case address
        when 0xFF04
          @div = 0x0000
          @tima = (@tima + 1) & 0xFF if timer_enabled? && div_falling_edge?
        when 0xFF05 then @tima = value & 0xFF
        when 0xFF06 then @tma = value & 0xFF
        when 0xFF07
          @previous_tac = @tac
          @tac = value & 0xFF
        end
      end

      private

      def previous_div
        (@div - 1) & 0xFFFF
      end

      def div_trigger_bit
        case clock_select
        when 0b00 then CLOCK_00_TRIGGER_BIT
        when 0b01 then CLOCK_01_TRIGGER_BIT
        when 0b10 then CLOCK_10_TRIGGER_BIT
        when 0b11 then CLOCK_11_TRIGGER_BIT
        end
      end

      def div_falling_edge?
        previous_div[div_trigger_bit] == 1 && @div[div_trigger_bit].zero?
      end

      def previous_tima
        (@tima - 1) & 0xFF
      end

      def tima_overflowed?
        previous_tima == 0xFF && @tima.zero?
      end

      def timer_enabled?
        @tac[2] == 1
      end

      def clock_select
        @tac & 0b11
      end

      def request_interrupt
        @interrupts.request(:timer)
      end
    end
  end
end
