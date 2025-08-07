# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles all possible Jump (JP) Instructions
      #
      # JP imm16             => Jumps to the immediate 16-bit address
      # JP [NZ|NC|Z|C],imm16 => Jumps to the immediate 16-bit address based on a flag
      # JP (HL)              => Jumps to the value contained in the HL register pair
      #
      class Jp
        attr_reader :mnemonic, :bytes, :t_cycles

        # @param address_mode [Symbol] Addressing mode (:imm16 or :mem_hl)
        # @param flag [Symbol] Which flag to check for the jump (C or Z)
        # @param value_check [Integer] Value to check in the flag (1 or 0)
        #
        def initialize(address_mode, flag = nil, value_check = nil)
          @address_mode = address_mode
          @flag = flag
          @value_check = value_check

          @mnemonic = current_mnemonic
          @bytes = current_bytes
          @t_cycles = current_t_cycles
        end

        def execute(cpu)
          @address_mode == :mem_hl ? jp_mem_hl(cpu) : jp_imm16(cpu)
        end

        private

        def condition
          condition = @flag.to_s.upcase.sub('_FLAG', '')
          @value_check == 1 ? condition : "N#{condition}"
        end

        def current_mnemonic
          return "JP #{@address_mode}" if @flag.nil?

          "JP #{[condition, @address_mode].join(',')}"
        end

        def current_bytes
          @address_mode == :mem_hl ? 1 : 3
        end

        def current_t_cycles
          return 4 if @address_mode == :mem_hl

          @flag.nil? ? 16 : [12, 16]
        end

        # M-cycle 1 => Fetches the opcode
        # M-cycle 2 => Fetches the 1st immediate byte (least significant)
        # M-cycle 3 => Fetches the 2nd immediate byte (most significant)
        #              Returns early if jump condition is not met
        # M-cycle 4 => If condition was met, calculate jump address and updates PC
        #
        def jp_imm16(cpu)
          lsb = cpu.fetch_next_byte
          msb = cpu.fetch_next_byte

          return if @flag && cpu.registers.send(@flag) != @value_check

          jump_address = (msb << 8) | lsb
          cpu.jump_to(jump_address)
        end

        # M-cycle 1 => Fetch opcode and jump to [HL]
        #
        def jp_mem_hl(cpu)
          jump_address = cpu.registers.hl
          cpu.registers.pc = jump_address
        end
      end
    end
  end
end
