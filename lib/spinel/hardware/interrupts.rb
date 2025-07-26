# frozen_string_literal: true

module Spinel
  module Hardware
    # Manages the Interrupt Enable (IE) and Interrupt Flag (IF) registers.
    class Interrupts
      INTERRUPTS = {
        vblank: 0,
        lcd: 1,
        timer: 2,
        serial: 3,
        joypad: 4
      }.freeze

      def initialize
        @registers = Registers.new
      end

      def read_byte(address)
        case address
        when 0xFF0F then @registers.if
        when 0xFFFF then @registers.ie
        end
      end

      def write_byte(address, value)
        case address
        when 0xFF0F then @registers.if = value
        when 0xFFFF then @registers.ie = value
        end
      end

      # Called by hardware (Timer, PPU, etc.) to request an interrupt
      def request(type)
        bit = INTERRUPTS[type]
        @if |= (1 << bit)
      end

      # Used internally by the CPU to clear a serviced interrupt flag
      def clear(bit)
        @if &= ~(1 << bit)
      end
    end
  end
end
