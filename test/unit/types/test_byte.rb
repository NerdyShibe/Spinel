# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/spinel/types/byte'

describe Spinel::Types::Byte do
  before do
    @byte1 = Spinel::Types::Byte.new(7)
    @byte2 = Spinel::Types::Byte.new(99)
    @byte3 = Spinel::Types::Byte.new(255)
    @byte4 = Spinel::Types::Byte.new(256)
  end

  describe '#initialize' do
    it 'instance of byte should be a numeric value' do
      [@byte1, @byte2, @byte3, @byte4].each do |byte|
        _(byte).must_be_kind_of Numeric
      end
    end

    it 'should wrap around if the value is greater than 255' do
      [@byte1, @byte2, @byte3, @byte4].each do |byte|
        _(byte.value).must_be :<, 256
      end
    end
  end

  describe '#in_decimal' do
    it 'should return the value in decimal as a string' do
      _(@byte1.in_decimal).must_equal '7'
      _(@byte2.in_decimal).must_equal '99'
      _(@byte3.in_decimal).must_equal '255'
      _(@byte4.in_decimal).must_equal '0'
    end
  end
end
