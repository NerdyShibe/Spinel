# frozen_string_literal: true

module Spinel
  # This class will describe the Game Boy Emulator
  class Emulator
    attr_accessor :status

    def initialize(rom_file)
      cartridge = Cartridge.new(rom_file)
      vram = Hardware::Vram.new
      wram = Hardware::Wram.new
      hram = Hardware::Cpu::Hram.new
      interrupts = Hardware::Interrupts.new
      serial = Hardware::Serial.new(interrupts)
      joypad = Hardware::Joypad.new
      @ppu = Hardware::Ppu.new

      @timer = Hardware::Timer.new(interrupts)
      bus = Hardware::Bus.new(cartridge, @ppu, vram, wram, hram, interrupts, serial, @timer, joypad)
      @cpu = Hardware::Cpu.new(self, bus, interrupts, serial)

      @status = :running

      run
    end

    def advance_cycles(cycles)
      cycles.times do
        @timer.tick
        @ppu.tick
      end
    end

    private

    # TODO: Implement boot loader
    def boot; end

    def run
      @cpu.run while @status == :running
      # 16_500.times do
      #   @cpu.run
      # end
    end
  end
end
