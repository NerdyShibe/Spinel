# frozen_string_literal: true

module Spinel
  module Util
    module Instructions
      # Handles the logic related to all possible Bit Control instructions
      #
      class BitControl
        attr_reader :mnemonic, :bytes, :cycles

        # @param operation [Symbol] Which type of Bit Control operation
        #
        def initialize(operation, bit_position, operand = nil)
          @operation = operation
          @bit_position = bit_position
          @operand = operand

          @mnemonic = metadata[:mnemonic]
          @bytes = metadata[:bytes]
          @cycles = metadata[:cycles]
        end

        def execute(cpu)
          case @operation
          when :bit then bit(cpu)
          when :bit_mem_hl then bit_mem_hl(cpu)
          when :res then res(cpu)
          when :res_mem_hl then res_mem_hl(cpu)
          when :set then set(cpu)
          when :set_mem_hl then set_mem_hl(cpu)
          else raise ArgumentError, "Invalid Bit Control operation: #{@operation}."
          end
        end

        private

        def metadata
          case @operation
          when :bit
            { mnemonic: "BIT #{@bit_position}, #{@operand}", bytes: 2, cycles: 8 }
          when :bit_mem_hl
            { mnemonic: "BIT #{@bit_position}, #{@operand}", bytes: 2, cycles: 12 }
          when :res
            { mnemonic: "RES #{@bit_position}, #{@operand}", bytes: 2, cycles: 8 }
          when :res_mem_hl
            { mnemonic: "RES #{@bit_position}, #{@operand}", bytes: 2, cycles: 16 }
          when :set
            { mnemonic: "SET #{@bit_position}, #{@operand}", bytes: 2, cycles: 8 }
          when :set_mem_hl
            { mnemonic: "SET #{@bit_position}, #{@operand}", bytes: 2, cycles: 16 }
          end
        end

        # M-cycle 1 => Fetch 0xCB prefix opcode
        # M-cycle 2 => Fetch current opcode and execute instruction
        #
        def bit(cpu)
          register = cpu.registers.send(@operand)
          bit_result = (register >> @bit_position) & 1

          cpu.registers.z_flag = bit_result.zero?
          cpu.registers.n_flag = false
          cpu.registers.h_flag = true
        end

        # M-cycle 1 => Fetch 0xCB prefix opcode
        # M-cycle 2 => Fetch current opcode
        # M-cycle 3 => Read value at (HL) and execute instruction
        # M-cycle 4 => Internal processing
        #
        def bit_mem_hl(cpu)
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          bit_result = (value_at_mem_hl >> @bit_position) & 1

          cpu.internal_delay

          cpu.registers.z_flag = bit_result.zero?
          cpu.registers.n_flag = false
          cpu.registers.h_flag = true
        end

        # M-cycle 1 => Fetch 0xCB prefix opcode
        # M-cycle 2 => Fetch current opcode and execute instruction
        #
        def res(cpu)
          register = cpu.registers.send(@operand)
          clear_mask = 1 << @bit_position

          result = register & ~clear_mask

          cpu.registers.send("#{@operand}=", result)
        end

        # M-cycle 1 => Fetch 0xCB prefix opcode
        # M-cycle 2 => Fetch current opcode
        # M-cycle 3 => Read value at (HL) and execute instruction
        # M-cycle 4 => Writes the result back to (HL)
        #
        def res_mem_hl(cpu)
          value_at_mem_hl = cpu.read_bus(cpu.registers.hl)
          clear_mask = 1 << @bit_position

          result = value_at_mem_hl & ~clear_mask
          cpu.write_bus(cpu.registers.hl, result)
        end

        # M-cycle 1 => Fetch 0xCB prefix opcode
        # M-cycle 2 => Fetch current opcode and execute instruction
        #
        def set(cpu)
          register = cpu.registers.send(@operand)
          set_mask = 1 << @bit_position

          result = register | set_mask

          cpu.registers.send("#{@operand}=", result)
        end

        # M-cycle 1 => Fetch 0xCB prefix opcode
        # M-cycle 2 => Fetch current opcode
        # M-cycle 3 => Read value at (HL) and execute instruction
        # M-cycle 4 => Writes the result back to (HL)
        #
        def set_mem_hl(cpu) # rubocop:disable Naming/AccessorMethodName
          value_at_mem_hl = cpu.bus_read(cpu.registers.hl)
          set_mask = 1 << @bit_position

          result = value_at_mem_hl | set_mask
          cpu.write_bus(cpu.registers.hl, result)
        end
      end
    end
  end
end
