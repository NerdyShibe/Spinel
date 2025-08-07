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

      INTERRUPT_VECTORS = {
        vblank: 0x0040,
        lcd_stat: 0x0048,
        timer: 0x0050,
        serial: 0x0058,
        joypad: 0x0060
      }.freeze

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

      # Checks if any interrupt was requested and is also currently enabled
      # (Same bit is set in both registers)
      #
      # @return [Boolean] `true` if any bit is enabled in both registers, `false` otherwise
      #
      def any_pending?
        @if.anybits?(@ie)
      end

      def pending?(interrupt_type)
        interrupt_bit = INTERRUPT_MAP[interrupt_type]

        (@if[interrupt_bit] & @ie[interrupt_bit]) == 1
      end

      # Signals an interrupt request by setting the
      # appropriate bit in the Interrupt Flag register
      #
      def request(interrupt_type)
        interrupt_bit = INTERRUPT_MAP[interrupt_type]

        @if |= (1 << interrupt_bit)
      end

      def priority_interrupt
        INTERRUPT_MAP.keys.find { |interrupt_type| pending?(interrupt_type) }
      end

      # Signals that an interrupt has been served by clearing the
      # appropriate bit in the Interrupt Flag register
      #
      def priority_service
        interrupt_bit = INTERRUPT_MAP[priority_interrupt]

        @if &= ~(1 << interrupt_bit)
      end

      def priority_vector
        INTERRUPT_VECTORS[priority_interrupt]
      end
    end
  end
end
