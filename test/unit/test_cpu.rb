# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/spinel/hardware/cpu'

class TestCpu < Minitest::Test
  def setup
    @cpu = Spinel::Hardware::Cpu.new
  end

  def test_that_ticks_starts_at_zero
    assert_equal @cpu.ticks, 0
  end

  def test_registers_initialization
    assert_equal @cpu.register_a, 0x00
    assert_equal @cpu.register_b, 0x00
    assert_equal @cpu.register_c, 0x00
    assert_equal @cpu.register_d, 0x00
    assert_equal @cpu.register_e, 0x00
  end
end
