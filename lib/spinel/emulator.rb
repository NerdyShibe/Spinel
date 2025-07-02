# frozen_string_literal: true

module Spinel
  # This class will describe the Game Boy Emulator
  class Emulator
    STATUSES = %w[paused running].freeze

    def initialize(file, status = 'paused')
      @status = status
      @cpu = Spinel::Cpu.new

      load_rom(file)
    end

    attr_accessor :status

    def paused?
      status == 'paused'
    end

    def running?
      status == 'running'
    end

    private

    def run
      while running?
        # Main core loop
        # Keep track of the registers
        # Initialize PC Register = $0100
        # Load run
        # Loop forever
        # next instruction
        # execute instruction
      end
    end

    # Load the ROM data
    def load_rom(rom_file)
      @rom = Cartridge::Rom.new(rom_file)
    end
  end
end
