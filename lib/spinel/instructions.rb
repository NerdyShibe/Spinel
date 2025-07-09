# frozen_string_literal: true

module Spinel
  module Instructions
    CPU_INSTRUCTIONS = [
      { mnemonic: 'NOP', length: 1, cycles: 4, method: :nop }, # 0x00
      { mnemonic: 'LD BC, d16', length: 3, cycles: 12, method: :ld_bc_d16 }, # 0x01
      { mnemonic: 'LD (BC), A', length: 1, cycles: 8, method: :ld_mem_bc_a } # 0x02
    ].freeze

    CB_PREFIX_INSTRUCTIONS = [
      # 0x00
    ].freeze
  end
end
