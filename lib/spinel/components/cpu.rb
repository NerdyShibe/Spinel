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
        @registers = Spinel::Cpu::Registers.new

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

        # First machine cycle (t-cycles 1-4)
        case @ticks
        when 1 then request_read
        when 2..3 then wait
        when 4 then receive_data && execute
        else execute
        end

        if @instruction && @ticks == @instruction[:cycles]
          reset_states
        else
          @ticks += 1
        end
      end

      private

      def request_read
        puts 'Requesting read from the bus...'
        @bus.request_read(@registers.pc)
        @bus.locked = true
      end

      def receive_data
        @opcode = @bus.return_data
        puts "Data received from the bus: 0x#{format('%02X', @opcode)}"
        @bus.locked = false
        @instruction = Data::CPU_INSTRUCTIONS[@opcode]
        @registers.pc += 1
      end

      def execute
        if @instruction[:operands].any?
          send(@instruction[:method], *@instruction[:operands])
        else
          send(@instruction[:method])
        end
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
