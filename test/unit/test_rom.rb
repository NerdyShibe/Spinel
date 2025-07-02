# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/spinel/cartridge/rom'

class TestRom < Minitest::Test
  def setup
    @rom = Spinel::Cartridge::Rom.new
  end
end
