# frozen_string_literal: true

module Spinel
  module Hardware
    # Represents the Sharp LR35902 CPU, a custom hybrid of the Z80 and 8080
    # processors, which serves as the core of the Nintendo Game Boy.
    #
    # The CPU is responsible for processing the game's logic by sequentially
    # executing instructions loaded from the cartridge ROM. It orchestrates all
    # operations within the Game Boy, from running game logic and handling user
    # input to controlling graphics and sound hardware.
    #
    class Cpu
      attr_accessor :ime_flag_schedule
      attr_reader :registers, :ticks, :opcode, :instruction

      def initialize(bus)
        @bus = bus
        @registers = Registers.new

        @ime_flag = true
        @ime_flag_schedule = :none
        @halted = false
        @stopped = false

        # Track internal states between ticks/cycles
        @ticks = 1
        @opcode = nil
        @instruction = nil

        @cb_prefix_mode = false
        @instructions = Util::Cpu::InstructionSet.build_unprefixed
        @cb_instructions = Util::Cpu::InstructionSet.build_cb_prefixed
        # debugger
      end

      # Each tick should be equivalent to 1 t-cycle
      # 1 machine cycle (m-cycle) = 4 t-cycles
      #
      def tick
        if !@halted && !@stopped
          puts "#{@ticks}   " \
               "#{format('%02X', @bus.read_byte(registers.pc))} " \
               "#{format('%02X', @bus.read_byte(registers.pc + 1))} " \
               "#{format('%02X', @bus.read_byte(registers.pc + 2))}"
          case @ticks
          when 1 then request_read
          when 2..3 then wait
          when 4 then receive_data && execute
          else execute
          end

          if @instruction && @ticks == @instruction.cycles
            @cb_prefix_mode = false unless @opcode == 0xCB
            update_ime_flag unless [0xF3, 0xFB].include?(@opcode) # DI / EI opcodes
            handle_interrupts
            reset_states
          else
            @ticks += 1
          end
        else
          handle_interrupts
        end
      end

      def request_read(address = @registers.pc)
        puts 'Requesting read from the bus...'
        @bus.request_read(address)
        @bus.locked = true
      end

      def receive_data
        byte = @bus.return_data
        @registers.pc += 1
        @bus.locked = false
        puts "Data received from the bus: 0x#{format('%02X', byte)}"

        return byte unless @opcode.nil?

        @opcode = byte
        @instruction = @instructions[@opcode]

        @opcode
      end

      def request_write(address)
        @bus.request_write(address)
      end

      def confirm_write(value)
        @bus.confirm_write(value)
      end

      private

      def wait
        puts 'Waiting...'
      end

      def execute
        instruction_set = @cb_prefix_mode ? @cb_instructions : @instructions
        instruction_set[@opcode].execute(self)
      end

      def update_ime_flag
        return false if @ime_flag_schedule == :none

        @ime_flag = true if @ime_flag_schedule == :enable
        @ime_flag = false if @ime_flag_schedule == :disable

        @ime_flag_schedule = :none
      end

      def handle_interrupts
        return false
        pending_interrupts = %w[ie_register ig_register]
        return if pending_interrupts.empty?

        @halted = false
        return unless @ime_flag

        # TODO: Serve interrupts by priority?
        serve_pending_interrupts = :not_implemented
      end

      def reset_states
        @ticks = 1
        @instruction = nil
        @opcode = nil

        puts 'Current instruction is now completed, resetting states...'
        puts "================================================================================================\n\n"
      end

      # def print_info
      #   @test_instruction = Data::OPCODES[@bus.read_byte(@registers.pc)]
      #   puts "$#{format('%04X', @registers.pc)}:  " \
      #        "(#{format('%02X', @bus.read_byte(@registers.pc))} " \
      #        "#{format('%02X', @bus.read_byte(@registers.pc + 1))} " \
      #        "#{format('%02X', @bus.read_byte(@registers.pc + 2))})  " \
      #        "A: #{format('%08B', @registers.a)}, " \
      #        "F: #{format('%08B', @registers.f)}, " \
      #        "B: #{format('%08B', @registers.b)}, " \
      #        "C: #{format('%08B', @registers.c)}, " \
      #        "D: #{format('%08B', @registers.d)}, " \
      #        "E: #{format('%08B', @registers.e)}, " \
      #        "H: #{format('%08B', @registers.h)}, " \
      #        "L: #{format('%08B', @registers.l)},  " \
      #        "#{@test_instruction[:mnemonic]} " \
      #        "#{@ticks} of #{@test_instruction[:cycles]}"
      # end
    end
  end
end
