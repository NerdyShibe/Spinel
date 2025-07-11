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
      include InstructionHandler

      attr_reader :registers, :ticks

      def initialize(bus)
        @bus = bus
        @registers = Registers.new
        @ime_flag = true
        @halted = false

        # Track internal states between ticks/cycles
        @ticks = 1
        @opcode = nil
        @instruction = nil
      end

      # Each tick should be equivalent to 1 t-cycle
      # 1 machine cycle (m-cycle) = 4 t-cycles
      #
      def tick
        return false if @halted

        puts "$#{format('%04X', @registers.pc)} Tick #{@ticks}"

        if @ticks == 1
          @opcode = fetch_byte
          @instruction = Data::CPU_INSTRUCTIONS[@opcode]
        else
          execute_instruction
        end

        if @ticks == @instruction[:cycles]
          reset_states
        else
          @ticks += 1
        end
      end

      private

      def fetch_byte
        byte = @bus.read(@registers.pc)
        if @ticks == 1
          puts "Fetched opcode: 0x#{format('%02X', byte)} Starting instruction..."
        else
          puts "Fetched byte: 0x#{format('%02X', byte)}..."
        end
        @registers.pc += 1

        byte
      end

      def execute_instruction
        send(@instruction[:method], @instruction[:operands]) if @instruction[:operands].any?
        send(@instruction[:method])
      end

      def reset_states
        @ticks = 1
        @instruction = nil
        @opcode = nil

        puts 'Current instruction is now completed, resetting states...'
        puts "=====================================================================\n\n"
      end
    end
  end
end
