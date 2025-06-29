# frozen_string_literal: true

require_relative 'spinel/cpu'
require_relative 'spinel/emu'
require_relative 'spinel/ppu'
require_relative 'spinel/rom'

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
  Spinel::Emu.new(file_path)
rescue Errno::ENOENT, file_path
  puts "Error: The file at #{file_path} does not exist"

  exit 3
end
