# frozen_string_literal: true

RSpec.describe Spinel::Util::Instructions::Jp do
  describe '#initialize' do
    context 'when creating JP imm16' do
      subject(:instruction) { described_class.new(:imm16) }

      it 'sets the correct mnemonic' do
        expect(instruction.mnemonic).to eq('JP imm16')
      end

      it 'sets the correct number of bytes' do
        expect(instruction.bytes).to eq(3)
      end

      it 'sets the correct number of cycles' do
        expect(instruction.t_cycles).to eq(16)
      end
    end

    context 'when creating JP NZ,imm16' do
      subject(:instruction) { described_class.new(:imm16, :z_flag, 0) }

      it 'sets the correct mnemonic' do
        expect(instruction.mnemonic).to eq('JP NZ,imm16')
      end

      it 'sets the correct number of bytes' do
        expect(instruction.bytes).to eq(3)
      end

      it 'sets the correct variable cycle count' do
        expect(instruction.t_cycles).to eq([12, 16])
      end
    end

    context 'when creating JP NC,imm16' do
      subject(:instruction) { described_class.new(:imm16, :c_flag, 0) }

      it 'sets the correct mnemonic' do
        expect(instruction.mnemonic).to eq('JP NC,imm16')
      end

      it 'sets the correct number of bytes' do
        expect(instruction.bytes).to eq(3)
      end

      it 'sets the correct variable cycle count' do
        expect(instruction.t_cycles).to eq([12, 16])
      end
    end

    context 'when creating JP Z,imm16' do
      subject(:instruction) { described_class.new(:imm16, :z_flag, 1) }

      it 'sets the correct mnemonic' do
        expect(instruction.mnemonic).to eq('JP Z,imm16')
      end

      it 'sets the correct number of bytes' do
        expect(instruction.bytes).to eq(3)
      end

      it 'sets the correct variable cycle count' do
        expect(instruction.t_cycles).to eq([12, 16])
      end
    end

    context 'when creating JP C,imm16' do
      subject(:instruction) { described_class.new(:imm16, :c_flag, 1) }

      it 'sets the correct mnemonic' do
        expect(instruction.mnemonic).to eq('JP C,imm16')
      end

      it 'sets the correct number of bytes' do
        expect(instruction.bytes).to eq(3)
      end

      it 'sets the correct variable cycle count' do
        expect(instruction.t_cycles).to eq([12, 16])
      end
    end

    context 'with an indirect jump (JP HL)' do
      subject(:instruction) { described_class.new(:mem_hl) }

      it 'sets the correct mnemonic' do
        expect(instruction.mnemonic).to eq('JP mem_hl')
      end

      it 'sets the correct number of bytes' do
        expect(instruction.bytes).to eq(1)
      end

      it 'sets the correct number of cycles' do
        expect(instruction.t_cycles).to eq(4)
      end
    end
  end

  describe '#execute' do
    context 'when executing 0xC3 Opcode => JP imm16' do
      subject(:instruction) { described_class.new(:imm16) }

      let(:registers) { instance_double(Spinel::Hardware::Cpu::Registers, pc: 0x0100, 'pc=': nil) }
      let(:cpu)       { instance_double(Spinel::Hardware::Cpu, registers: registers) }

      before do
        allow(cpu).to receive(:bus_read).and_return(0x50, 0x01)
        allow(cpu).to receive(:calculate_address).and_return(0x0150)
      end

      it 'reads two bytes from the bus and jumps the PC to the correct address' do
        instruction.execute(cpu)

        expect(registers).to have_received(:pc=).with(0x0150)
      end
    end
  end
end
