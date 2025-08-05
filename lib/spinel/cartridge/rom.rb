# frozen_string_literal: true

module Spinel
  class Cartridge
    #
    # When the game is loaded
    # this class needs to map all possible
    # ROM banks (each one should be 16 KiB)
    #
    class Rom
      attr_reader :data

      # @param rom_file [String] Path to the rom file
      #
      def initialize(rom_file)
        # Will have an array of bytes in decimal format [0, 255]
        @data = File.binread(rom_file).bytes

        # print_full_info
      end

      def read_byte(address)
        # TODO: Implement Bank switching logic
        data[address]
      end

      def write_byte(address, value)
        # TODO: Implement Bank switching logic
        data[address] = value & 0xFF
      end

      # Each cartridge contains a header, located at the address range $0100—$014F.
      # The cartridge header provides information about the game itself
      # and the hardware it expects to run on
      def header
        data[0x0100..0x014F]
      end

      # After displaying the Nintendo logo, the built-in boot ROM jumps to the address $0100,
      # which should then jump to the actual main program in the cartridge.
      # Most commercial games fill this 4-byte area with a nop instruction
      # followed by a jp $0150.
      def entry_point
        data[0x0104..0x0133]
      end

      def nintendo_logo
        data[0x0104..0x0133].map { |decimal| format('%02X', decimal) }
      end

      # 0134-0143 — Title
      # These bytes contain the title of the game in upper case ASCII.
      # If the title is less than 16 characters long, the remaining bytes
      # should be padded with $00s.
      #
      # Parts of this area actually have a different meaning on later cartridges,
      # reducing the actual title size to 15 ($0134–$0142) or 11 ($0134–$013E) characters
      def title
        data[0x0134..0x0143].map(&:chr)
      end

      def manufacturer_code
        data[0x13F..0x0142].map(&:chr)
      end

      def cgb_flag
        data[0x0143]
      end

      def new_licensee_code
        data[0x0144..0x0145].map(&:chr)
      end

      # This byte specifies whether the game supports SGB functions
      def sgb_flag
        format('%02X', data[0x0146])
      end

      def type
        value = format('%02X', data[0x0147])
        Constants::CARTRIDGE_TYPES[value]
      end

      def rom_size
        value = format('%02X', data[0x0148])
        Constants::ROM_SIZES[value]
      end

      def ram_size
        value = format('%02X', data[0x0149])
        Constants::RAM_SIZES[value]
      end

      # This byte specifies the version number of the game.
      # It is usually $00.
      def version_number
        data[0x014C].map(&:chr)
      end

      def header_checksum
        checksum = 0
        bytes = data[0x0134..0x014C]

        bytes.each do |byte|
          checksum = checksum - byte - 1
        end

        checksum
      end

      def global_checksum
        checksum = 0

        # 0x014E and 0x014F addresses are excluded from the checksum
        bytes = data.reject.with_index do |_byte, address|
          (0x014E..0x014F).cover?(address)
        end

        bytes.each do |byte|
          checksum += byte
        end

        checksum
      end

      def verify_header_checksum
        # We only need to check the lower 8 bits
        # header_checksum is a 16bit number
        # bitwise AND 0b00001111 to extract the lower 8 bits on big endian format
        return 'PASSED!' if data[0x014D] == header_checksum & 0xFF

        'FAILED!'
      end

      def verify_global_checksum
        # We only need to check the lower 16 bits
        # pack the 2 bytes from decimal to 8bit
        # unpack the 8bit array to a 16bit format
        # unpack('S>') for big endian format
        # unpack('S<') for little endian format
        u16int = data[0x014E..0x014F].pack('C*').unpack1('S>')
        return 'PASSED!' if u16int == global_checksum & 0xFFFF

        'FAILED!'
      end

      def print_full_info
        puts '--- ROM Information ---'
        puts "Nintendo Logo: #{nintendo_logo}"
        puts "Title: #{title}"
        puts "Type: #{type}"
        puts "ROM Size: #{rom_size}"
        puts "RAM Size: #{ram_size}"
        puts "Manufacturer Code: #{manufacturer_code}"
        puts "CGB Flag: #{cgb_flag}"
        puts "New Licensee Code: #{new_licensee_code}"
        puts "Header Checksum Status: #{verify_header_checksum}"
        puts "Global Checksum Status: #{verify_global_checksum}"
      end
    end
  end
end
