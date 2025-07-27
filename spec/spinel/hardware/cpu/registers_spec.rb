# frozen_string_literal: true

RSpec.describe Spinel::Hardware::Cpu::Registers, type: :cpu do
  subject(:registers) { described_class.new }

  describe '#initialize' do
    it 'initializes the A register with 0x01' do
      expect(registers.a).to eq(0x01)
    end

    it 'initializes the F register with 0xB0' do
      expect(registers.f).to eq(0xB0)
    end

    it 'initializes the B register with 0x00' do
      expect(registers.b).to eq(0x00)
    end

    it 'initializes the C register with 0x13' do
      expect(registers.c).to eq(0x13)
    end

    it 'initializes the D register with 0x00' do
      expect(registers.d).to eq(0x00)
    end

    it 'initializes the E register with 0xD8' do
      expect(registers.e).to eq(0xD8)
    end

    it 'initializes the H register with 0x01' do
      expect(registers.h).to eq(0x01)
    end

    it 'initializes the L register 0x4D' do
      expect(registers.l).to eq(0x4D)
    end

    it 'initializes the Stack Pointer (SP) with 0xFFFE' do
      expect(registers.sp).to eq(0xFFFE)
    end

    it 'initializes the Program Counter (PC) with 0x0100' do
      expect(registers.pc).to eq(0x0100)
    end
  end

  %i[a b c d e h l].each do |register|
    describe "##{register}=" do
      it "stores the value into the #{register.upcase} register" do
        registers.send("#{register}=", 0x69)

        expect(registers.send(register)).to eq(0x69)
      end

      it 'handles values bigger than 0xFF (255)' do
        registers.send("#{register}=", 0x100)

        expect(registers.send(register)).to eq(0x00)
      end
    end
  end

  describe '#af' do
    it 'returns the correct value after storing values into A' do
      registers.a = 0x69

      expect(registers.af).to eq(0x69B0)
    end

    it 'handles overflow from the A register (> 0xFF)' do
      registers.a = 0x100

      expect(registers.af).to eq(0x00B0)
    end
  end

  describe '#af=' do
    it 'stores the upper byte value into the A register' do
      registers.af = 0xABCD

      expect(registers.a).to eq(0xAB)
    end

    it 'stores the lower byte value into the F register, lower 4 bits are always 0' do
      registers.af = 0xFFFF

      expect(registers.f).to eq(0xF0)
    end

    it 'handles overflow if a value bigger than 0xFFFF is provided' do
      registers.af = 0x1FFFF

      expect(registers.a).to eq(0xFF)
      expect(registers.f).to eq(0xF0)
    end
  end

  %i[bc de hl].each do |register_pair|
    upper_register = register_pair.to_s.chars.first.to_sym
    lower_register = register_pair.to_s.chars.last.to_sym

    # Getters
    describe "##{register_pair}" do
      it "returns the correct value after storing #{upper_register.upcase} and #{lower_register.upcase}" do
        registers.send("#{upper_register}=", 0xDC)
        registers.send("#{lower_register}=", 0xBA)

        expect(registers.send(register_pair)).to eq(0xDCBA)
      end

      it "handles overflow from the upper register #{upper_register.upcase}" do
        registers.send("#{upper_register}=", 0x1FF)
        registers.send("#{lower_register}=", 0xCD)

        expect(registers.send(register_pair)).to eq(0xFFCD)
      end

      it "handles overflow from the lower register #{lower_register.upcase}" do
        registers.send("#{upper_register}=", 0xAB)
        registers.send("#{lower_register}=", 0x1FF)

        expect(registers.send(register_pair)).to eq(0xABFF)
      end
    end

    # Setters
    describe "##{register_pair}=" do
      it "stores the upper byte value into the #{upper_register.upcase} register" do
        registers.send("#{register_pair}=", 0xABCD)

        expect(registers.send(upper_register)).to eq(0xAB)
      end

      it "stores the lower byte value into the #{lower_register.upcase} register" do
        registers.send("#{register_pair}=", 0xABCD)

        expect(registers.send(lower_register)).to eq(0xCD)
      end

      it 'handles overflow if a value bigger than 0xFFFF is provided' do
        registers.send("#{register_pair}=", 0x10000)

        expect(registers.send(upper_register)).to eq(0x00)
        expect(registers.send(lower_register)).to eq(0x00)
      end
    end
  end

  describe '#sp=' do
    it 'stores the word value into the Stack Pointer (SP)' do
      registers.sp = 0xABCD

      expect(registers.sp).to eq(0xABCD)
    end

    it 'handles overflow if a value bigger than 0xFFFF is provided' do
      registers.sp = 0x1FFFF

      expect(registers.sp).to eq(0xFFFF)
    end
  end

  describe '#pc=' do
    it 'stores the word value into the Program Counter (PC)' do
      registers.pc = 0xABCD

      expect(registers.pc).to eq(0xABCD)
    end

    it 'handles overflow if a value bigger than 0xFFFF is provided' do
      registers.pc = 0x1FFFF

      expect(registers.pc).to eq(0xFFFF)
    end
  end

  %i[z_flag n_flag h_flag c_flag].each do |flag|
    describe "##{flag}=" do
      it 'assigning true sets the correct Bit in the Flags (F) register' do
        registers.send("#{flag}=", true)

        expect(registers.send(flag)).to eq(1)
      end

      it 'assigning false clears the correct Bit in the Flags (F) register' do
        registers.send("#{flag}=", false)

        expect(registers.send(flag)).to eq(0)
      end
    end
  end
end
