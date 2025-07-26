# frozen_string_literal: true

module Spinel
  module Util
    module Errors
      class NotImplementedError < StandardError; end
      class MemoryOutOfBoundsError < StandardError; end
    end
  end
end
