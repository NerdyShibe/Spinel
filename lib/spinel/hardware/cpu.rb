# frozen_string_literal: true

module Spinel
  module Hardware
    # Represents the Sharp LR35902 CPU, a custom hybrid of the Z80 and 8080
    # processors, which serves as the core of the Nintendo Game Boy.
    #
    # The CPU is responsible for processing the game's logic by sequentially
    # executing instructions loaded from the cartridge ROM. It orchestrates all
    # operations within the Game Boy, from running game logic and handling user
    # input to controlling graphics and sound hardware.
    #
    class Cpu
      attr_accessor :ime_flag_schedule, :m_cycles
      attr_reader :registers, :opcode, :instruction

      def initialize(emu, bus, interrupts)
        @emu = emu
        @bus = bus
        @interrupts = interrupts
        @registers = Registers.new

        @ime_flag = true
        @ime_flag_schedule = :none
        @halted = false
        @stopped = false

        # Track internal states between ticks/cycles
        @m_cycles = 0
        @opcode = nil
        @instruction = nil

        @cb_prefix_mode = false
        @instructions = Util::InstructionSet.build_unprefixed
        @cb_instructions = Util::InstructionSet.build_cb_prefixed
        # debugger
      end

      def run
        if !@halted && !@stopped
          debug_info
          fetch_instruction
          execute
        else
          handle_interrupts
        end
      end

      def advance_cycles
        @m_cycles += 1
        @emu.advance_cycles(4)
      end

      def fetch_next_byte
        byte = @bus.read_byte(@registers.pc)
        @registers.pc += 1
        advance_cycles

        byte
      end

      def bus_read(address)
        byte = @bus.read_byte(address)
        advance_cycles

        byte
      end

      def bus_write(address, value)
        @bus.write_byte(address, value)
        advance_cycles
      end

      def calculate_address(lsb, msb)
        address = (msb << 8) | lsb
        advance_cycles

        address
      end

      def sign_value(unsigned_byte)
        signed_byte = unsigned_byte >= 128 ? (unsigned_byte - 256) : unsigned_byte
        advance_cycles

        signed_byte
      end

      def add16(value1, value2)
        sum = value1 + value2
        advance_cycles

        sum
      end

      def sub16(value1, value2)
        sub = value1 - value2
        advance_cycles

        sub
      end

      def load16(register, value)
        @registers.send("#{register}=", value)
        advance_cycles
      end

      private

      def fetch_instruction
        @opcode = fetch_next_byte
      end

      def execute
        instruction_set = @cb_prefix_mode ? @cb_instructions : @instructions
        instruction_set[@opcode].execute(self)
      end

      def handle_interrupts
        pending_interrupts = @interrupts.read_byte(0xFFFF) & @interrupts.read_byte(0xFF0F)

        return if pending_interrupts.zero?

        @halted = false
        return unless @ime_flag

        # TODO
        puts 'Serve interrupts by priority 0 -> 5, 1 per cycle'
        # serve_pending_interrupts = :not_implemented
      end

      def debug_info
        instruction_set = @cb_prefix_mode ? @cb_instructions : @instructions
        instruction = instruction_set[@bus.read_byte(@registers.pc)]
        puts "#{format('%08d', @m_cycles)}  " \
             "$#{format('%04X', @registers.pc)}:  " \
             "#{instruction.mnemonic.ljust(20, ' ')}" \
             "(#{format('%02X', @bus.read_byte(@registers.pc))} " \
             "#{format('%02X', @bus.read_byte(@registers.pc + 1))} " \
             "#{format('%02X', @bus.read_byte(@registers.pc + 2))} " \
             "#{format('%02X', @bus.read_byte(@registers.pc + 3))} " \
             "#{format('%02X', @bus.read_byte(@registers.pc + 4))})     " \
             "F: #{format('%08B', @registers.f)}, " \
             "A: #{format('%02X', @registers.a)}, " \
             "B: #{format('%02X', @registers.b)}, " \
             "C: #{format('%02X', @registers.c)}, " \
             "D: #{format('%02X', @registers.d)}, " \
             "E: #{format('%02X', @registers.e)}, " \
             "H: #{format('%02X', @registers.h)}, " \
             "L: #{format('%02X', @registers.l)}  " \
      end

      # def update_ime_flag
      #   return false if @ime_flag_schedule == :none

      #   @ime_flag = true if @ime_flag_schedule == :enable
      #   @ime_flag = false if @ime_flag_schedule == :disable

      #   @ime_flag_schedule = :none
      # end
    end
  end
end
