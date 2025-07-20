# frozen_string_literal: true

module Spinel
  # This class will describe the Game Boy Emulator
  class Emulator
    STATUSES = %w[paused running].freeze

    def initialize(rom_file, status = 'paused')
      @status = status

      @rom = Cartridge::Rom.new(rom_file)
      @vram = Hardware::Vram.new
      @bus = Hardware::Bus.new(@rom, @vram)
      @cpu = Hardware::SoC::Cpu.new(@bus)

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
      while running?
        @cpu.tick
        # @ppu.tick
        # @apu.tick
        # @timer.tick
      end
    end
  end
end
