# frozen_string_literal: true

module Spinel
  # This class will describe the Game Boy Emulator
  class Emulator
    STATUSES = %w[paused running].freeze

    def initialize(rom_file, status = 'paused')
      @status = status

      @rom = Devices::RomBank.new(rom_file)
      @bus = Hardware::Bus.new(@rom)
      @cpu = Hardware::Cpu.new(@bus)

      boot
    end

    attr_accessor :status

    def paused?
      status == 'paused'
    end

    def running?
      status == 'running'
    end

    private

    def boot
      @status = 'running'
      # Main core loop
      # Keep track of the registers
      # Initialize PC Register = $0100
      # Load run
      # Loop forever
      # next instruction
      # execute instruction
      while running?
        @cpu.tick
      end
    end
  end
end
