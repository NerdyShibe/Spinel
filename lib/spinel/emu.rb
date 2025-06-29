module Spinel
  class Emu
    def initialize(attribute)
      @attribute = attribute

      cpu = Spinel::Cpu.new
      ppu = Spinel::Ppu.new
    end

    def run
      # Main core loop
      # Keep track of the registers
      # Initialize PC Register = $0100
      # Load run
      # Loop forever
      # next instruction
      # execute instruction
    end

    private

    def load_rom(rom_path)
      # load rom data
    end
  end
end
