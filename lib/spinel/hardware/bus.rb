# frozen_string_literal: true

module Spinel
  module Hardware
    #
    # This Class represents the 16-bit address bus of the Game Boy
    # Which is used to map the address values for the ROM, RAM, and I/O.
    #
    # Memory Map
    # ===============================================================================================
    # Start	End	  Description	                    Notes
    # 0000  3FFF	16 KiB ROM bank 00	            From cartridge, usually a fixed bank
    # 4000	7FFF	16 KiB ROM Bank 01–NN	          From cartridge, switchable bank via mapper (if any)
    # 8000	9FFF	8 KiB Video RAM (VRAM)	        In CGB mode, switchable bank 0/1
    # A000	BFFF	8 KiB External RAM	            From cartridge, switchable bank if any
    # C000	CFFF	4 KiB Work RAM (WRAM)
    # D000	DFFF	4 KiB Work RAM (WRAM)	          In CGB mode, switchable bank 1–7
    # E000	FDFF	Echo RAM (mirror of C000–DDFF)	Nintendo says use of this area is prohibited.
    # FE00	FE9F	Object attribute memory (OAM)
    # FEA0	FEFF	Not Usable	                    Nintendo says use of this area is prohibited.
    # FF00	FF7F	I/O Registers
    # FF80	FFFE	High RAM (HRAM)
    # FFFF	FFFF	Interrupt Enable register (IE)
    # ===============================================================================================
    #
    class Bus
      attr_accessor :locked

      def initialize(cartridge, vram, wram)
        @cartridge = cartridge
        @vram = vram
        @wram = wram

        @locked = false
        @data_latch = 0x00
        @address_latch = 0x0000
      end

      def request_read(address)
        @address_latch = address
      end

      def return_data
        read_byte(@address_latch)
      end

      def request_write(address)
        @address_latch = address
      end

      def confirm_write(value)
        write_byte(@address_latch, value)
      end

      # Delegates which component should be involved
      # depending on the address range
      #
      # @param address [Integer] => 16-bit value
      # @return [Integer] => 8-bit value
      #
      def read_byte(address)
        case address
        when 0x0000..0x7FFF
          @cartridge.read_byte(address)
        when 0x8000..0x9FFF
          @vram.read_byte(address)
        when 0xC000..0xDFFF
          @wram.read_byte(address)
        else
          raise("This part of memory was not mapped yet: $#{format('%04X', address)}")
        end
      end

      # Delegates which component should write the data
      # depending on the address range
      #
      # @param address [Integer] => 16-bit value
      # @return [Integer] => 8-bit value
      #
      def write_byte(address, byte)
        case address
        when 0x0000..0x7FFF
          @cartridge.write_byte(address, byte)
        when 0x8000..0x9FFF
          @vram.write_byte(address, byte)
        when 0xC000..0xDFFF
          @wram.write_byte(address, byte)
        else
          raise("This part of memory was not mapped yet: $#{format('%04X', address)}")
        end
      end
    end
  end
end
