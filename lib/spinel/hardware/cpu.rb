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
      attr_accessor :ime_flag_schedule, :ime_flag, :m_cycles, :halted
      attr_reader :registers, :interrupts, :opcode, :instruction

      def initialize(emu, bus, interrupts, serial_port)
        @emu = emu
        @bus = bus
        @interrupts = interrupts
        @serial_port = serial_port

        @registers = Registers.new

        @ime_flag = false
        @ime_flag_schedule = false
        @halted = false
        @stopped = false

        # Track internal states between ticks/cycles
        @m_cycles = 0
        @opcode = nil
        @instruction = nil

        @instructions = Util::InstructionSet.build_unprefixed
        @cb_instructions = Util::InstructionSet.build_cb_prefixed
      end

      def run
        if @interrupts.any_pending?
          if @ime_flag
            @halted = false if @halted

            interrupt_service_routine
            return
          elsif @halted
            @halted = false
          end
        end

        check_ime_schedule

        if @halted
          @emu.advance_cycles(4)
          return
        end

        debug_info
        fetch_instruction
        execute
      end

      def advance_cycles(m_cycles)
        @m_cycles += 1
        @emu.advance_cycles(m_cycles * 4)
      end

      def internal_delay(cycles:)
        advance_cycles(cycles)
      end

      def fetch_next_byte
        byte = @bus.read_byte(@registers.pc)
        @registers.pc += 1
        advance_cycles(1)

        byte
      end

      def bus_read(address)
        byte = @bus.read_byte(address)
        advance_cycles(1)

        byte
      end

      def bus_write(address, value)
        @bus.write_byte(address, value)
        advance_cycles(1)
      end

      def sign_value(byte)
        byte >= 128 ? (byte - 256) : byte
      end

      def add16(value1, value2)
        sum = value1 + value2
        advance_cycles(1)

        sum
      end

      def sub16(value1, value2)
        sub = value1 - value2
        advance_cycles(1)

        sub
      end

      def load16(register, value)
        @registers.send("#{register}=", value)
        advance_cycles(1)
      end

      def stack_push(value)
        @registers.sp -= 1
        bus_write(@registers.sp, value)
      end

      def stack_push16(value)
        stack_push((value >> 8) & 0xFF)
        stack_push(value & 0xFF)
      end

      def stack_pop
        popped_value = bus_read(@registers.sp)
        @registers.sp += 1

        popped_value
      end

      def stack_pop16
        lsb = stack_pop
        msb = stack_pop

        (msb << 8) | lsb
      end

      def jump_to(address)
        advance_cycles(1)

        @registers.pc = address
      end

      private

      def fetch_instruction
        @cb_prefix_mode = false
        @opcode = fetch_next_byte

        if @opcode == 0xCB
          @opcode = fetch_next_byte
          @cb_prefix_mode = true
        end

        @instruction = @cb_prefix_mode ? @cb_instructions[@opcode] : @instructions[@opcode]
      end

      def execute
        @instruction.execute(self)
      end

      # Disables IME flag, gets address vector to jump to
      # Services the priority interrupt, pushes the current PC to the stack
      # Jumps to the address vector
      #
      # 2 M-cycles of internal processing
      # 2 M-cycles to write the current PC to the stack
      # 1 M-cycle to jump to address vector
      #
      def interrupt_service_routine
        internal_delay(cycles: 2)
        @ime_flag = false

        address_vector = @interrupts.priority_vector
        @interrupts.priority_service

        stack_push16(@registers.pc)
        jump_to(address_vector)
      end

      def check_ime_schedule
        return unless @ime_flag_schedule

        @ime_flag = @ime_flag_schedule
        @ime_flag_schedule = false
      end

      def debug_info
        # instruction_set = @bus.read_byte(@registers.pc) == 0xCB ? @cb_instructions : @instructions
        # instruction = instruction_set[@bus.read_byte(@registers.pc)]

        # puts "#{format('%08d', @m_cycles)} || " \
        #      "$#{format('%04X', @registers.pc)} || " \
        #      "#{instruction.mnemonic.ljust(20, ' ')}" \
        #      "(#{format('%02X', @bus.read_byte(@registers.pc))} " \
        #      "#{format('%02X', @bus.read_byte(@registers.pc + 1))} " \
        #      "#{format('%02X', @bus.read_byte(@registers.pc + 2))}) || " \
        #      "F: #{format('%04B', @registers.f >> 4)}, " \
        #      "A: #{format('%02X', @registers.a)}, " \
        #      "BC: #{format('%04X', @registers.bc)}, " \
        #      "DE: #{format('%04X', @registers.de)}, " \
        #      "HL: #{format('%04X', @registers.hl)} || " \
        #      "SP: $#{format('%04X', @registers.sp)} || "

        puts "\n\n##{@m_cycles} SERIAL MESSAGE: #{@serial_port.message_buffer.join}"
      end
    end
  end
end
