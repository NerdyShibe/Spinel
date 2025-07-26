# frozen_string_literal: true

module Spinel
  module Hardware
    class Timer
      #
      # The rule for the DIV counter's frequency is:
      # Bit n flips every 2^(n+1) T-cycles.
      #
      # Applying this to the 1024 frequency (TAC setting = 00):
      #
      # 2^(n+1) = 1024 = 2^10
      # n + 1 = 10
      # n = 9
      #
      # To get a signal that happens every 1024 T-cycles,
      # the hardware must watch bit 9 of the internal DIV counter.
      #
      # Here is how all four TAC settings map to the bits of the DIV counter:
      #
      # TAC bits 1-0	Frequency (T-cycles)	 Math	     Bit to Watch
      #    00	        1024	                 2^(9+1)	 Bit 9
      #    01	        16	                   2^(3+1)	 Bit 3
      #    10	        64	                   2^(5+1)	 Bit 5
      #    11	        256	                   2^(7+1)	 Bit 7
      #
      BIT_1024 = 9
      BIT_16   = 3
      BIT_64   = 5
      BIT_256  = 7
    end
  end
end
