# frozen_string_literal: true

require 'debug'
require 'benchmark'
require 'stackprof'

require_relative 'spinel/emulator'

require_relative 'spinel/cartridge/base'
require_relative 'spinel/cartridge/mbc'
require_relative 'spinel/cartridge/ram'
require_relative 'spinel/cartridge/rom'

require_relative 'spinel/hardware/bus'
require_relative 'spinel/hardware/soc/apu'
require_relative 'spinel/hardware/soc/cpu'
require_relative 'spinel/hardware/soc/hram'
require_relative 'spinel/hardware/soc/registers'
require_relative 'spinel/hardware/soc/ppu'
require_relative 'spinel/hardware/timer'
require_relative 'spinel/hardware/vram'
require_relative 'spinel/hardware/wram'

require_relative 'spinel/util/cpu/instruction_set'
require_relative 'spinel/util/cpu/opcodes'
require_relative 'spinel/util/constants'

require_relative 'spinel/util/cpu/instructions/base'
base_path = File.join(__dir__, 'spinel/util/cpu/instructions/*.rb')

Dir.glob(base_path).each do |file|
  require file
end

#
# TODO: Write detailed comment about the Spinel module
module Spinel
  VERSION = '0.0.1'

  unless defined?(RSpec)
    # Get the ROM file from command line argument
    file_path = ARGV[0]

    # Verify if the argument was provided
    if file_path.nil?
      puts 'Error: You must provide a path to a GB rom'
      puts 'Usage: $ ruby lib/spinel.rb /path/to/rom.gb'

      exit 1
    end

    # Do not allow directories as arguments
    if File.directory?(file_path)
      puts 'Error: Path provided is a directory'
      puts 'Usage: $ ruby lib/spinel.rb /path/to/rom.gb'

      exit 2
    end

    begin
      # Creates the initial instance of the Emulator
      # to start the emulation process
      StackProf.run(mode: :cpu, out: 'tmp/stackprof-cpu-spinel.dump') do
        Spinel::Emulator.new(file_path)
      end
    rescue Errno::ENOENT, file_path
      puts "Error: The file at #{file_path} does not exist"

      exit 3
    end
  end
end
