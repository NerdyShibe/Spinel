# frozen_string_literal: true

module Spinel
  module Hardware
    # Implements the Serial Communication
    #
    # Hardware Registers
    # $FF01  SB  Serial Transfer Data
    # $FF02  SC  Serial Transfer Control
    #
    class SerialPort
      attr_reader :sb, :message_buffer

      # @param interrupt [Object] Instance of the interrupt main object
      #
      def initialize(interrupt)
        @interrupt = interrupt

        @sb = 0x00
        @sc = 0x00

        @message_buffer = []
      end

      # Sets the Serial Transfer Data to a given value
      # A byte is set before starting the communication
      #
      # @param value [Integer] Value to set into the register
      # @return [Integer] 8-bit value set into the register
      #
      def sb=(value)
        @sb = value & 0xFF
      end

      # Only bits 0, 1 and 7 are used
      # But Bit1 is Game Boy Color only, will ignore for now
      # Other bits should be pulled high (1) when read
      #
      # Bit7 => Transfer enable
      # Bit1 => Clock speed (CGB mode only)
      # Bit0 => Clock select
      #
      # | 7* | 6 | 5 | 4 | 3 | 2 | 1* | 0* |
      #
      def sc
        @sc | 0b01111110
      end

      # Sets the Serial Transfer Control to a given value
      # Stores only the relevant bits, the other ones are set to 0
      # Triggers the data transfer if Bit 7 is set
      #
      # @param value [Integer] 8-bit value to be used
      # @return [Integer] 8-bit value with 2 relevant bits set
      #
      def sc=(value)
        @sc = value & 0b10000001

        transfer_data if transfer_requested?
      end

      private

      def transfer_data
        capture_message
        complete_transfer
        request_interrupt
      end

      # Checks if Bit 7 of the Serial Transfer Control
      # is set to determine if a transfer was requested
      #
      def transfer_requested?
        @sc[7] == 1
      end

      # Captures the byte that was stored in the
      # Serial Transfer Data before the transfer was requested,
      # converts the byte value to a ASCII character
      # and stores it in a message buffer
      #
      def capture_message
        @message_buffer << @sb.chr
      end

      # Clears Bit 7 of the Serial Transfer Control register
      # This signals that the transfer is completed
      #
      def complete_transfer
        @sc & 0b011111111
      end

      # After the transfer is completed an interrupt should
      # be requested for the Serial type
      #
      def request_interrupt
        @interrupt.request(:serial)
      end
    end
  end
end
