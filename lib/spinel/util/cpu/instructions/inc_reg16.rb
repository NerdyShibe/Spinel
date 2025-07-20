# frozen_string_literal: true

module Spinel
  module CpuInstructions
    # Defines all possible Increment (INC) instructions
    #
    class IncReg16
      attr_reader :mnemonic, :cycles

      def initialize(reg16)
        super(mnemonic: "INC #{reg16.to_s.upcase}", length: 1, cycles: 8)

        @reg16 = reg16
      end

      def execute(ticks)
        case ticks
        when 8
          value = @registers.send(@reg16)
          result = (value + 1) & 0xFFFF

          @registers.z_flag = result.zero?
          @registers.n_flag = false
          @registers.h_flag = ((value & 0x00FF) + 1) > 0x00FF

          @registers.set_value(@reg16, result)
        else
          wait
        end
      end
    end
  end
end
