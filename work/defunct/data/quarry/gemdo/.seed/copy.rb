#!/usr/bin/env ruby

# This seed creates GEM DO POM metadata files. By default, or
# selecting the `meta` type, the files generated are: 
#
#   meta/data.rb
#   meta/package
#   meta/profile
#
# If the `top` selection is made the files are:
#
#   PROFILE
#   VERSION
#
# The default is highly recommeded.

utilize 'gemdo'

argument :name

name = data.name

#name = arguments.first || metadata['name'] #|| destination.basename.to_s

abort "Name is required."         unless name
abort "Name must be single word." unless name =~ /\w+/

data.title   = data['title']   || name.capitalize
data.contact = data['contact'] || data['email']

if data.top
  copy "**/*", :render=>'erb', :from=>'top'
else
  copy "**/*", :render=>'erb', :from=>'meta'
end

