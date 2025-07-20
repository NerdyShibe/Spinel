# frozen_string_literal: true

module Spinel
  module CpuInstructions
    # Defines all possible Increment (INC) instructions
    #
    class NotImplemented
      def execute(_ticks)
        abort('Not implemented yet')
      end
    end
  end
end
