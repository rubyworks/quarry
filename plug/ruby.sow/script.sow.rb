#!/usr/bin/env ruby

help "Scaffold a traditional ruby project."

usage "ruby [options] <name>"

#option(:dummy, "just a dummy option") do |val|
#  metadata.dummy = val
#end

argument(:name, 'name of new project') do |val|
  abort "Name is required." unless val
  metadata.package = val
end

manifest do
  copy('**/*', '.')
  copy('.meta/*', metadir)
end

