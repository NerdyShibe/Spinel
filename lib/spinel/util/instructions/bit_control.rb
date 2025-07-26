# frozen_string_literal: true

module Spinel
  module Util
    module Cpu
      module Instructions
        # Handles the logic related to all possible Bit Control instructions
        #
        class BitControl
          # @param operation [Symbol] Which type of Bit Control operation
          #
          def initialize(operation, bit_position, operand = nil)
            @operation = operation
            @bit_position = bit_position
            @operand = operand

            super(
              mnemonic: metadata[:mnemonic],
              bytes: metadata[:bytes],
              cycles: metadata[:cycles]
            )
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

          def bit(cpu)
            case cpu.ticks
            when 8
              register = cpu.registers.send(@operand)
              bit_result = (register >> @bit_position) & 1

              cpu.registers.z_flag = bit_result.zero?
              cpu.registers.n_flag = false
              cpu.registers.h_flag = true
            else wait
            end
          end

          def bit_mem_hl(cpu)
            case cpu.ticks
            when 8 then cpu.request_read(cpu.registers.hl)
            when 12
              fetched_byte = cpu.receive_data
              bit_result = (fetched_byte >> @bit_position) & 1

              cpu.registers.z_flag = bit_result.zero?
              cpu.registers.n_flag = false
              cpu.registers.h_flag = true
            else wait
            end
          end

          def res(cpu)
            case cpu.ticks
            when 8
              register = cpu.registers.send(@operand)
              clear_mask = 1 << @bit_position

              result = register & ~clear_mask

              cpu.registers.send("#{@operand}=", result)
            else wait
            end
          end

          def res_mem_hl(cpu)
            case cpu.ticks
            when 8 then cpu.request_read(cpu.registers.hl)
            when 12
              fetched_byte = cpu.receive_data
              clear_mask = 1 << @bit_position

              @result = fetched_byte & ~clear_mask
            when 13 then cpu.request_write(cpu.registers.hl)
            when 16 then cpu.confirm_write(@result)
            else wait
            end
          end

          def set(cpu)
            case cpu.ticks
            when 8
              register = cpu.registers.send(@operand)
              set_mask = 1 << @bit_position

              result = register | set_mask

              cpu.registers.send("#{@operand}=", result)
            else wait
            end
          end

          def set_mem_hl(cpu) # rubocop:disable Naming/AccessorMethodName
            case cpu.ticks
            when 8 then cpu.request_read(cpu.registers.hl)
            when 12
              fetched_byte = cpu.receive_data
              set_mask = 1 << @bit_position

              @result = fetched_byte | set_mask
            when 13 then cpu.request_write(cpu.registers.hl)
            when 16 then cpu.confirm_write(@result)
            else wait
            end
          end
        end
      end
    end
  end
end
