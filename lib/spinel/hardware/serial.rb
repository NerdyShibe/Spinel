# frozen_string_literal: true

module Spinel
  module Hardware
    # Serial Port
    #
    class Serial
      attr_reader :message

      # @param interrupts [Object] An object that manages the IF register ($FF0F)
      def initialize(interrupts)
        @interrupts = interrupts

        @sb = 0x00
        @sc = 0x00

        @message = ''
      end

      def read_byte(address)
        case address
        when 0xFF01 then @sb
        when 0xFF02 then @sc
        end
      end

      def write_byte(address, value)
        case address
        when 0xFF01 then @sb = value
        when 0xFF02
          @sc = value
          if transfer_requested?
            # 1. Print the character from the data register
            @message << @sb.chr

            complete_transfer

            # 3. Request a serial interrupt so the ROM knows it's done
            @interrupts.request(:serial)
          end
        end
      end

      private

      def transfer_requested?
        @sc == 0x81
      end

      # Clear Bit7
      #
      def complete_transfer
        @sc &= 0b01111111
      end
    end
  end
end
