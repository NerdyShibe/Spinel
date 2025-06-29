# frozen_string_literal: true

module Spinel
  # Represents the Sharp LR35902 CPU, a custom hybrid of the Z80 and 8080
  # processors, which serves as the core of the Nintendo Game Boy.
  #
  # The CPU is responsible for processing the game's logic by sequentially
  # executing instructions loaded from the cartridge ROM. It orchestrates all
  # operations within the Game Boy, from running game logic and handling user
  # input to controlling graphics and sound hardware.
  #
  # Core Architecture:
  #
  # * **Registers:** The CPU uses a set of internal memory units called registers
  #   to store data and control program flow at high speed. These include:
  #   - 8-bit general-purpose registers: A (Accumulator), B, C, D, E, H, L.
  #   - 8-bit Flag register (F): Its bits are set or cleared based on the
  #     results of the last operation (e.g., Zero, Carry flags).
  #   - 16-bit special-purpose registers:
  #     - SP (Stack Pointer): Tracks the stack for function calls and returns.
  #     - PC (Program Counter): Holds the memory address of the next
  #       instruction to be executed.
  #
  # The Instruction Cycle:
  #
  # The CPU's fundamental operation is a continuous three-step cycle, which is
  # represented by the private methods in this class:
  #
  # 1.  **Fetch:** Reads the next instruction (a 8-bit opcode) from the memory
  #     location pointed to by the Program Counter (PC).
  # 2.  **Decode:** Interprets the fetched opcode to determine the corresponding
  #     action and identify any necessary data (operands).
  # 3.  **Execute:** Performs the decoded action. This could involve arithmetic,
  #     data manipulation between registers and memory, or altering the
  #     program flow (e.g., jumps, calls). After execution, the cycle repeats.
  #
  class Cpu
    def initialize
      @register_a = 0x00
      @register_b = 0x00
      @register_c = 0x00
      @register_d = 0x00
      @register_e = 0x00
    end

    attr_reader :register_a,
                :register_b,
                :register_c,
                :register_d,
                :register_e

    private

    def fetch(instruction)
      # fetch instruction
    end

    def decode(instruction)
      # decode instruction
    end

    def execute(instruction)
      # execute instruction
    end

    # define Registers
  end
end
