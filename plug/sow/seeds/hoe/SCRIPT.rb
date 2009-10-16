#!/usr/bin/env ruby

about "Scaffold a new Hoe ready project."

usage "hoe [options] <name>"

argument :name do |name|
  abort "Project name argument required." unless name
  metadata.name = name
end

copy "**/*", '.'

