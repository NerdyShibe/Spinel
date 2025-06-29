# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/spinel/cpu'

RSpec.describe Spinel::Cpu do
  subject(:cpu) { described_class.new }

  describe '#initialize' do
    it 'should initialize all registers with 0' do
      expect(cpu.register_a).to eq(0x00)
      expect(cpu.register_b).to eq(0x00)
      expect(cpu.register_c).to eq(0x00)
      expect(cpu.register_d).to eq(0x00)
      expect(cpu.register_e).to eq(0x00)
    end
  end
end
