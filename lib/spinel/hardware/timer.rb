# frozen_string_literal: true

module Spinel
  module Hardware
    # Describes the Game Boy built-in Timer
    #
    class Timer
      # The more accurate way to determine if TIMA needs to be
      # incremented is to watch a specific Bit in the DIV Register
      # for a falling edge (change from 1 to 0)
      #
      TRIGGER_BIT_FOR_00_CLOCK = 9
      TRIGGER_BIT_FOR_01_CLOCK = 3
      TRIGGER_BIT_FOR_10_CLOCK = 5
      TRIGGER_BIT_FOR_11_CLOCK = 7

      def initialize(interrupts)
        @interrupts = interrupts
        @registers  = Registers.new

        @div_trigger_bit  = div_trigger_bit
        @timer_enabled    = @registers.tac_enable == 1
        @tima_overflowed  = false
        @tima_reset_delay = 4
      end

      def tick
        @previous_div = @registers.div
        @registers.div += 1

        if tima_overflowed?
          @tima_reset_delay -= 1

          return unless @tima_reset_delay.zero?

          reset_tima
          request_interrupt
        else
          return unless timer_enabled? && div_falling_edge?

          @registers.tima += 1
          @tima_overflowed = true if @registers.tima.zero?
        end
      end

      def read_registers(address)
        case address
        when 0xFF04 then @registers.div >> 8
        when 0xFF05 then @registers.tima
        when 0xFF06 then @registers.tma
        when 0xFF07 then @registers.tac
        end
      end

      # When writing to DIV the total value of the 16-bit counter
      # is reset, this can cause a falling edge in the trigger bit
      # if it was set right before the write (1 => 0)
      #
      def write_registers(address, value)
        case address
        when 0xFF04
          @previous_div = @registers.div
          @registers.div = 0x0000
          # TODO: Check for falling edge on trigger bit
        when 0xFF05 then @registers.tima = value
        when 0xFF06 then @registers.tma = value
        when 0xFF07
          @previous_tac = @registers.tac
          @registers.tac = value
          update_div_trigger_bit
          update_timer_enabled
          # TODO: Check for falling edge on TAC
        end
      end

      private

      def div_trigger_bit
        case @registers.tac_clock_select
        when 0b00 then TRIGGER_BIT_FOR_00_CLOCK
        when 0b01 then TRIGGER_BIT_FOR_01_CLOCK
        when 0b10 then TRIGGER_BIT_FOR_10_CLOCK
        when 0b11 then TRIGGER_BIT_FOR_11_CLOCK
        end
      end

      def div_falling_edge?
        return false if @previous_div[@div_trigger_bit].zero?

        @registers.div[@div_trigger_bit].zero?
      end

      def update_div_trigger_bit
        @div_trigger_bit = div_trigger_bit
      end

      def timer_enabled?
        @timer_enabled
      end

      def update_timer_enabled
        @timer_enabled = @registers.tac_enable == 1
      end

      def tima_overflowed?
        @tima_overflowed
      end

      def reset_tima
        @registers.tima = @registers.tma
        @tima_overflowed = false
        @tima_reset_delay = 4
      end

      def request_interrupt
        @interrupts.request(:timer)
      end
    end
  end
end
