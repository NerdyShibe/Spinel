# frozen_string_literal: true

module Spinel
  # This class will describe the Game Boy Emulator
  class Emulator
    attr_accessor :status

    def initialize(rom_file)
      rom = Cartridge::Rom.new(rom_file)
      vram = Hardware::Vram.new
      wram = Hardware::Wram.new
      hram = Hardware::Cpu::Hram.new
      interrupts = Hardware::Interrupts.new
      serial = Hardware::Serial.new(interrupts)
      ppu = Hardware::Ppu.new

      @timer = Hardware::Timer.new(interrupts)
      bus = Hardware::Bus.new(rom, ppu, vram, wram, hram, interrupts, serial, @timer)
      @cpu = Hardware::Cpu.new(self, bus, interrupts)

      @status = :running

      run
    end

    def advance_cycles(cycles)
      cycles.times do
        @timer.tick
      end
    end

    private

    # TODO: Implement boot loader
    def boot; end

    def run
      5.times do
        @cpu.run
        # @cpu.run while @status == :running
      end
    end
  end
end
