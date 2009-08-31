#!/usr/bin/env ruby

help "Scaffold a bin command."

#usage "--bin[=command_name]"

argument(:name, 'name of command file') do |val|
  val = val || pathname
  abort "Exectuable name is required." unless val
  abort "Executable name must be a single word." if /\w/ !~ val
  val
end

scaffold do
  copy 'bin/command.rb', "bin/#{name}", :chmod => 0755
end

