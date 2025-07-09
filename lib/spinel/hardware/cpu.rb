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
      def initialize
        @ticks = 0

        @bus = Bus.new
        @registers = Registers.new
      end

      attr_reader :ticks

      private

      def fetch(instruction)
        # fetch instruction
      end

      def decode(instruction)
        # decode instruction
      end

      def execute(instruction)
        # execute instruction
      end

      def tick
        # 1 cycle
      end

      def halted?
        # Check for halt interrupts
      end
    end
  end
end
