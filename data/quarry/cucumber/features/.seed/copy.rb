#!/usr/bin/env ruby

# Create a new cucumber feature file.
# 
#   name      - the name of the new feature (required)
#   directory - the features directory (default `features/`)
#
argument :name
argument :directory 

abort "feature name is required" unless meatadata.name

directory = metadata.directory || 'features'

scaffold do
  copy "__feature__.feature", directory
end

# TODO: Perhaps add automatic detection of location of features?