# rubocop:disable RSpec/MultipleMemoizedHelpers
# frozen_string_literal: true

RSpec.describe Spinel::Hardware::Bus, type: :bus do
  subject(:bus) { described_class.new(rom, ppu, vram, wram, hram, interrupts, serial, timer) }

  let(:rom)        { instance_double(Spinel::Cartridge::Rom) }
  let(:ppu)        { instance_double(Spinel::Hardware::Ppu) }
  let(:vram)       { instance_double(Spinel::Hardware::Vram) }
  let(:wram)       { instance_double(Spinel::Hardware::Wram) }
  let(:hram)       { instance_double(Spinel::Hardware::Cpu::Hram) }
  let(:interrupts) { instance_double(Spinel::Hardware::Interrupts) }
  let(:serial)     { instance_double(Spinel::Hardware::Serial) }
  let(:timer)      { instance_double(Spinel::Hardware::Timer) }

  describe '#read_byte' do
    context 'when in the Cartridge default ROM bank address range $0000-$3FFF' do
      before do
        allow(rom).to receive(:read_byte).with(0x0000).and_return(0x69)
        allow(rom).to receive(:read_byte).with(0x3FFF).and_return(0x42)
      end

      it 'maps the address $0000 to the cartridge ROM' do
        bus.read_byte(0x0000)

        expect(rom).to have_received(:read_byte).with(0x0000)
      end

      it 'maps the address $3FFF to the cartridge ROM' do
        bus.read_byte(0x3FFF)

        expect(rom).to have_received(:read_byte).with(0x3FFF)
      end
    end

    # TODO: Pending ROM bank switch implementation
    context 'when in the Cartridge switchable ROM Bank address range $4000-$7FFF' do
      before do
        allow(rom).to receive(:read_byte).with(0x4000).and_return(0x99)
        allow(rom).to receive(:read_byte).with(0x7FFF).and_return(0x12)
      end

      it 'maps the address $4000 to the cartridge ROM' do
        bus.read_byte(0x4000)

        expect(rom).to have_received(:read_byte).with(0x4000)
      end

      it 'maps the address $7FFF to the cartridge ROM' do
        bus.read_byte(0x7FFF)

        expect(rom).to have_received(:read_byte).with(0x7FFF)
      end
    end

    context 'when in the VRAM address range $8000-$9FFF' do
      before do
        allow(vram).to receive(:read_byte)
        allow(vram).to receive(:read_byte)
      end

      it 'maps the address $8000 to the VRAM' do
        bus.read_byte(0x8000)

        expect(vram).to have_received(:read_byte).with(0x8000)
      end

      it 'maps the address $9FFF to the VRAM' do
        bus.read_byte(0x9FFF)

        expect(vram).to have_received(:read_byte).with(0x9FFF)
      end
    end

    context 'when in the external Cartridge RAM address range $A000-$BFFF' do
      it 'maps the address $A000 to the external Cartridge RAM' do
        skip('Pending implementation')
      end

      it 'maps the address $BFFF to the external Cartridge RAM' do
        skip('Pending implementation')
      end
    end

    context 'when in the Work RAM address range $C000-$CFFF' do
      before do
        allow(wram).to receive(:read_byte)
        allow(wram).to receive(:read_byte)
      end

      it 'maps the address $C000 to the Work RAM' do
        bus.read_byte(0xC000)

        expect(wram).to have_received(:read_byte).with(0xC000)
      end

      it 'maps the address $CFFF to the Work RAM' do
        bus.read_byte(0xCFFF)

        expect(wram).to have_received(:read_byte).with(0xCFFF)
      end
    end

    context 'when in the Work RAM address range $D000-$DFFF' do
      before do
        allow(wram).to receive(:read_byte)
        allow(wram).to receive(:read_byte)
      end

      it 'maps the address $D000 to the Work RAM' do
        bus.read_byte(0xD000)

        expect(wram).to have_received(:read_byte).with(0xD000)
      end

      it 'maps the address $DFFF to the Work RAM' do
        bus.read_byte(0xDFFF)

        expect(wram).to have_received(:read_byte).with(0xDFFF)
      end
    end

    context 'when in the Echo RAM address range $E000-$FDFF' do
      before do
        allow(wram).to receive(:read_byte)
        allow(wram).to receive(:read_byte)
      end

      it 'mirrors the address of the Work RAM at $E000 - $2000' do
        bus.read_byte(0xE000)

        expect(wram).to have_received(:read_byte).with(0xE000 - 0x2000)
      end

      it 'mirrors the address of the Work RAM at $FDFF - $2000' do
        bus.read_byte(0xFDFF)

        expect(wram).to have_received(:read_byte).with(0xFDFF - 0x2000)
      end
    end

    context 'when in the Object Attribute Memory (OAM) address range $FE00-$FE9F' do
      before do
        allow(ppu).to receive(:read_oam)
        allow(ppu).to receive(:read_oam)
      end

      it 'maps the $FE00 to the OAM inside the PPU' do
        bus.read_byte(0xFE00)

        expect(ppu).to have_received(:read_oam).with(0xFE00)
      end

      it 'maps the $FE9F to the OAM inside the PPU' do
        bus.read_byte(0xFE9F)

        expect(ppu).to have_received(:read_oam).with(0xFE9F)
      end
    end
  end
end

# rubocop:enable RSpec/MultipleMemoizedHelpers
