# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/spinel/types/word'

describe Spinel::Types::Word do
  before do
    @word1 = Spinel::Types::Word.new(256)
    @word2 = Spinel::Types::Word.new(4096)
    @word3 = Spinel::Types::Word.new(65_535)
    @word4 = Spinel::Types::Word.new(65_536)
  end

  describe '#initialize' do
    it 'should be a Numeric value' do
      [@word1, @word2, @word3, @word4].each do |word|
        _(word).must_be_kind_of Numeric
      end
    end

    it 'should wrap around if the value is greater than 65535' do
      [@word1, @word2, @word3, @word4].each do |word|
        _(word.value).must_be :<, 65_536
      end
    end
  end

  describe '#in_decimal' do
    it 'should return the decimal value as string' do
      _(@word1.in_decimal).must_equal '256'
      _(@word2.in_decimal).must_equal '4096'
      _(@word3.in_decimal).must_equal '65535'
      _(@word4.in_decimal).must_equal '0'
    end
  end
end
