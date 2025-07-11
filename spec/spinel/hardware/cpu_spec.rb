# frozen_string_literal: true

RSpec.describe Spinel::Hardware::Cpu, type: :cpu do
  subject(:cpu) { described_class.new(mock_bus) }

  let(:mock_bus) { instance_double(Spinel::Hardware::Bus) }

  describe '#initialize' do
    it 'initializes the registers' do
      expect(cpu.registers).to be_an_instance_of(Spinel::Hardware::Registers)
    end
  end

  describe '#tick' do
    context 'when handling the (0x00 => NOP) instruction' do
      before do
        cpu.registers.pc = 0xC000
        opcode = 0x00
        allow(mock_bus).to receive(:read).with(0xC000).and_return(opcode)
      end

      it 'takes 4 cycles to complete' do
        4.times { cpu.tick }

        expect(cpu.registers.pc).to eq(0xC001)
      end
    end

    context 'when handling the (0xC3 => JP a16) instruction' do
      let(:bytes) { [0xC3, 0x50, 0x01] } #=> JP $150

      before do
        cpu.registers.pc = 0xC000
        load_program(mock_bus, bytes, start_address: 0xC000)
      end

      it 'fetches the opcode, low byte, high byte and jumps to address' do
        # Cycles 1-4
        expect { 4.times { cpu.tick } }.to change(cpu.registers, :pc).from(0xC000).to(0xC001)
        expect(mock_bus).to have_received(:read).with(0xC000).once

        # Cycles 5-8
        expect { 4.times { cpu.tick } }.to change(cpu.registers, :pc).from(0xC001).to(0xC002)
        expect(mock_bus).to have_received(:read).with(0xC001).once
        expect(cpu.operand_low).to eq(0x50)

        # Cycles 9-12
        expect { 4.times { cpu.tick } }.to change(cpu.registers, :pc).from(0xC002).to(0xC003)
        expect(mock_bus).to have_received(:read).with(0xC002).once
        expect(cpu.operand_high).to eq(0x01)

        # Cycles 13-15
        expect { 3.times { cpu.tick } }.not_to change(cpu.registers, :pc)

        # Cycle 16
        expect { cpu.tick }.to change(cpu.registers, :pc).from(0xC003).to(0x0150)
      end
    end
  end
end
