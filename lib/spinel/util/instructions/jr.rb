# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles all possible Jump Relative (JR) Instructions
      #
      # JR sig8             => Jumps relative to a signed 8-bit offset
      # JR [NZ|NC|Z|C],sig8 => Jumps relative to a signed 8-bit offset based on a flag
      #
      class Jr
        attr_reader :mnemonic, :bytes, :t_cycles

        # @param address_mode [Symbol] Addressing mode (:sig8)
        # @param flag [Symbol] Which flag to check for the jump (C or Z)
        # @param value_check [Integer] Value to check in the flag (1 or 0)
        #
        def initialize(address_mode, flag = nil, value_check = nil)
          @address_mode = address_mode
          @flag = flag
          @value_check = value_check

          @mnemonic = current_mnemonic
          @bytes = 2
          @t_cycles = current_t_cycles
        end

        def execute(cpu)
          jr_sig8(cpu)
        end

        private

        def condition
          condition = @flag.to_s.upcase.sub('_FLAG', '')
          @value_check == 1 ? condition : "N#{condition}"
        end

        def current_mnemonic
          return "JR #{@address_mode}" if @flag.nil?

          "JR #{[condition, @address_mode].join(',')}"
        end

        def current_t_cycles
          @flag.nil? ? 12 : [8, 12]
        end

        # M-cycle 1 => Fetches the opcode
        # M-cycle 2 => Fetches the immediate byte
        #              Returns early if jump condition is not met
        # M-cycle 3 => Converts byte to signed value and adds to PC
        #
        def jr_sig8(cpu)
          unsigned_byte = cpu.fetch_next_byte

          return if @flag && cpu.registers.send(@flag) != @value_check

          signed_byte = cpu.sign_value(unsigned_byte)
          cpu.registers.pc += signed_byte
        end
      end
    end
  end
end
