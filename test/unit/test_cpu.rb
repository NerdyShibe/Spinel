require_relative '../test_helper'
require_relative '../../lib/spinel/cpu'

describe Spinel::Cpu do
  before do
    @cpu = Spinel::Cpu.new
  end

  describe '#initialize' do
    it 'initializes the registers' do
      _(@cpu.register_a).must_equal 0x00
      _(@cpu.register_b).must_equal 0x00
      _(@cpu.register_c).must_equal 0x00
      _(@cpu.register_d).must_equal 0x00
      _(@cpu.register_e).must_equal 0x00
    end
  end
end
