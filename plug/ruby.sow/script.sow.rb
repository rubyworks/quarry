#!/usr/bin/env ruby

about "Scaffold a traditional ruby project."

usage "--ruby[=<package-name>]"

argument(:name, 'package name of new application/library') do |val|
  val = val || pathname
  abort "Name is required." unless val
  metadata.package = val
end

scaffold do
  copy('**/*', '.')
  copy('.meta/*', metadir)
end

