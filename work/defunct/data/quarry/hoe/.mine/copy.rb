#!/usr/bin/env ruby

# Hoe seed makes up for the fact the Sow clobber's
# Hoe's +sow+ command.
# 
# Usage:
# 
#   sow hoe [-o pathname | name]
# 
# Note the usage is slighly different from the original
# hoe command. To put the scaffolding in a subdirectory
# you need to supply the --output option.
#
# Hoe plugin, to make up for the fact the Sow clobber's
# Hoe's +sow+ command. Isn't it a bit silly to have a
# command called +sow+ when it could just as well be
# called +hoe+ anyway?

abort "For new projects only." unless empty? #_or_managed

data.name = arguments.shift || output.basename.to_s

#abort "Project name argument required." unless metadata.name

copy "**/*", :from=>'template'

