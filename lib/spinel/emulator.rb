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
      @cpu.tick while running?
    end
  end
end
