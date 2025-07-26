# frozen_string_literal: true

RSpec.describe Spinel::Util::Instructions::Jr do
  describe '#initialize' do
    context 'when creating JR sig8' do
      subject(:instruction) { described_class.new }

      it 'sets the correct mnemonic' do
        expect(instruction.mnemonic).to eq('JR sig8')
      end

      it 'sets the correct number of bytes' do
        expect(instruction.bytes).to eq(2)
      end

      it 'sets the correct number of cycles' do
        expect(instruction.t_cycles).to eq(12)
      end
    end

    context 'when creating JR NZ,sig8' do
      subject(:instruction) { described_class.new(:z_flag, 0) }

      it 'sets the correct mnemonic' do
        expect(instruction.mnemonic).to eq('JR NZ,sig8')
      end

      it 'sets the correct number of bytes' do
        expect(instruction.bytes).to eq(2)
      end

      it 'sets the correct variable cycle count' do
        expect(instruction.t_cycles).to eq([8, 12])
      end
    end

    context 'when creating JR NC,sig8' do
      subject(:instruction) { described_class.new(:c_flag, 0) }

      it 'sets the correct mnemonic' do
        expect(instruction.mnemonic).to eq('JR NC,sig8')
      end

      it 'sets the correct number of bytes' do
        expect(instruction.bytes).to eq(2)
      end

      it 'sets the correct variable cycle count' do
        expect(instruction.t_cycles).to eq([8, 12])
      end
    end

    context 'when creating JR Z,sig8' do
      subject(:instruction) { described_class.new(:z_flag, 1) }

      it 'sets the correct mnemonic' do
        expect(instruction.mnemonic).to eq('JR Z,sig8')
      end

      it 'sets the correct number of bytes' do
        expect(instruction.bytes).to eq(2)
      end

      it 'sets the correct variable cycle count' do
        expect(instruction.t_cycles).to eq([8, 12])
      end
    end

    context 'when creating JR C,sig8' do
      subject(:instruction) { described_class.new(:c_flag, 1) }

      it 'sets the correct mnemonic' do
        expect(instruction.mnemonic).to eq('JR C,sig8')
      end

      it 'sets the correct number of bytes' do
        expect(instruction.bytes).to eq(2)
      end

      it 'sets the correct variable cycle count' do
        expect(instruction.t_cycles).to eq([8, 12])
      end
    end
  end
end
