# frozen_string_literal: true

module Spinel
  module CpuInstructions
    # Defines all possible Increment (INC) instructions
    #
    class Nop
      def execute(_ticks)
        puts 'Doing nothing...'
      end
    end
  end
end
