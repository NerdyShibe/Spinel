# frozen_string_literal: true

module CpuHelper
  # Configures a mock bus to respond with a sequence of bytes,
  # simulating a program loaded at a specific address.
  #
  # @param bus [RSpec::Mocks::Double] The mock bus to configure.
  # @param bytes [Array<Integer>] An array of 8-bit integers representing the program.
  # @param start_address [Integer] The memory address where the program starts.
  #
  def load_program(bus, bytes, start_address: 0x0000)
    bytes.each_with_index do |byte, offset|
      address = start_address + offset
      allow(bus).to receive(:read).with(address).and_return(byte)
    end
  end
end
