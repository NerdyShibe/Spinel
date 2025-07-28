# frozen_string_literal: true

module Spinel
  module Hardware
    # This will describe the Emulator Timer
    class Timer
      def initialize(interrupts)
        @interrupts = interrupts

        @registers = Registers.new
      end

      def tick
        old_bit_trigger = @registers.div_bit_trigger
        @registers.div += 1

        return unless update_tima?(old_bit_trigger)

        @registers.tima += 1

        # Check for TIMA overflow from 0xFF to 0x00
        return unless @registers.tima.zero?

        @registers.tima = @registers.tma
        request_interrupt
      end

      def read_byte(address)
        case address
        when 0xFF04 then (@registers.div >> 8)
        when 0xFF05 then @registers.tima
        when 0xFF06 then @registers.tma
        when 0xFF07 then @registers.tac
        end
      end

      def write_byte(address, value)
        case address
        when 0xFF04
          old_trigger_bit = @registers.div_bit_trigger
          @registers.div = 0x00

          increment_tima if timer_enabled? && old_trigger_bit == 1
        when 0xFF05 then @registers.tima = value
        when 0xFF06 then @registers.tma = value
        when 0xFF07
          old_trigger_bit = @registers.div_bit_trigger
          was_enabled = timer_enabled?

          @registers.tac = value

          new_trigger_bit = @registers.div_bit_trigger
          is_now_disabled = !timer_enabled?

          increment_tima if timer_enabled? && old_trigger_bit == 1 && new_trigger_bit.zero?

          increment_tima if was_enabled && is_now_disabled && (old_trigger_bit == 1)
        end
      end

      private

      def timer_enabled?
        @registers.tac_enable == 1
      end

      def update_tima?(old_bit_trigger)
        return false unless timer_enabled?

        new_bit_trigger = @registers.div_trigger_bit

        # Check for a falling edge 1 => 0 in the specified bit
        old_bit_trigger.allbits?(1) && new_bit_trigger.nobits?(0)
      end

      def request_interrupt
        @interrupts.request(Interrupts::Types::TIMER)
      end
    end
  end
end
