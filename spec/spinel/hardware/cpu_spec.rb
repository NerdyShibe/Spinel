# frozen_string_literal: true

RSpec.describe Spinel::Hardware::Cpu, type: :cpu do
  subject(:cpu) { described_class.new(emu, bus, interrupts, serial) }

  let(:emu)        { instance_double(Spinel::Emulator) }
  let(:bus)        { instance_double(Spinel::Hardware::AddressBus) }
  let(:interrupts) { instance_double(Spinel::Hardware::Interrupts) }
  let(:serial)     { instance_double(Spinel::Hardware::Serial) }

  describe '#initialize' do
    it 'initializes the registers' do
      expect(cpu.registers).to be_an_instance_of(Spinel::Hardware::Cpu::Registers)
    end

    it 'starts at 0 m-cycles' do
      expect(cpu.m_cycles).to eq(0)
    end
  end

  describe '#bus_read' do
    before do
      allow(emu).to receive(:advance_cycles)
      allow(bus).to receive(:read_byte).with(0x0100).and_return(0x69)
    end

    it 'fetches the correct value from the bus' do
      fetched_byte = cpu.bus_read(0x0100)

      expect(fetched_byte).to eq(0x69)
    end

    it 'increments the amount of m-cycles on the Cpu by 1' do
      expect { cpu.bus_read(0x0100) }.to change(cpu, :m_cycles).from(0).to(1)
    end

    it 'advances the total emulator t-cycles by 4' do
      cpu.bus_read(0x0100)

      expect(emu).to have_received(:advance_cycles).with(4)
    end
  end

  describe '#bus_write' do
    before do
      allow(emu).to receive(:advance_cycles)
      allow(bus).to receive(:write_byte).with(0x0100, 0x69)
    end

    it 'correctly calls the bus to write the value at that address' do
      cpu.bus_write(0x100, 0x69)

      expect(bus).to have_received(:write_byte).with(0x0100, 0x69)
    end

    it 'increments the amount of m-cycles on the Cpu by 1' do
      expect { cpu.bus_write(0x100, 0x69) }.to change(cpu, :m_cycles).from(0).to(1)
    end

    it 'advances the total emulator t-cycles by 4' do
      cpu.bus_write(0x100, 0x69)

      expect(emu).to have_received(:advance_cycles).with(4)
    end
  end
end
