# frozen_string_literal: true

module Spinel
  module Hardware
    # Implements the Serial Communication
    #
    # Hardware Registers
    # $FF0F: Interrupt Flag (IF)   => Signals if a given interrupt was requested
    # $FFFF: Interrupt Enable (IE) => Signals if a given interrupt is enabled
    #
    class Interrupts
      INTERRUPT_MAP = {
        vblank: 0,
        lcd_stat: 1,
        timer: 2,
        serial: 3,
        joypad: 4
      }.freeze

      VBLANK_VECTOR   = 0x0040
      LCD_STAT_VECTOR = 0x0048
      TIMER_VECTOR    = 0x0050
      SERIAL_VECTOR   = 0x0058
      JOYPAD_VECTOR   = 0x0060

      def initialize
        @if = 0x00
        @ie = 0x00
      end

      # Only Bits 4-0 are used
      # Bits 7-5 are always pulled high
      #
      def if
        @if | 0b11100000
      end

      def if=(value)
        @if = value & 0b00011111
      end

      # Only Bits 4-0 are used
      # Bits 7-5 are always pulled high
      #
      def ie
        @ie | 0b11100000
      end

      def ie=(value)
        @ie = value & 0b00011111
      end

      # Signals an interrupt request by setting the
      # appropriate bit in the Interrupt Flag register
      #
      def request(interrupt_type)
        interrupt_bit = INTERRUPT_MAP[interrupt_type]

        @if |= (1 << interrupt_bit)
      end

      # Signals that an interrupt has been served by clearing the
      # appropriate bit in the Interrupt Flag register
      #
      def service(interrupt_type)
        interrupt_bit = INTERRUPT_MAP[interrupt_type]

        @if &= ~(1 << interrupt_bit)
      end

      def priority_vector
        if vblank_pending?
          VBLANK_VECTOR
        elsif lcd_stat_pending?
          LCD_STAT_VECTOR
        elsif timer_pending?
          TIMER_VECTOR
        elsif serial_pending?
          SERIAL_VECTOR
        elsif joypad_pending?
          JOYPAD_VECTOR
        end
      end

      def clear_priority_bit
        if vblank_pending?
          service(:vblank)
        elsif lcd_stat_pending?
          service(:vblank)
        elsif timer_pending?
          service(:timer)
        elsif serial_pending?
          service(:serial)
        elsif joypad_pending?
          service(:joypad)
        end
      end

      # Checks if an interrupt was requested and is also currently enabled
      # (Same bit is set in both registers)
      #
      # @return [Boolean] `true` if any bit is enabled in both registers, `false` otherwise
      #
      def pending?
        @if.anybits?(@ie)
      end

      def vblank_pending?
        @if[0] & @ie[0] != 0
      end

      def lcd_stat_pending?
        @if[1] & @ie[1] != 0
      end

      def timer_pending?
        @if[2] & @ie[2] != 0
      end

      def serial_pending?
        @if[3] & @ie[3] != 0
      end

      def joypad_pending?
        @if[4] & @ie[4] != 0
      end
    end
  end
end
