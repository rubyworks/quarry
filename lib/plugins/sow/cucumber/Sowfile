#!/usr/bin/env ruby

# Create a new cucumber feature file.
# 
#   feature   - the name of the new feature (required)
#   directory - the features directory (default `features/`)
#
# Setup a project for use with Cucumber testing framework.
# This seed takes two optional arguments.
#
#   directory - where to put features (defaults to 'features/')
#   feature   - name of your first feature file (defaults to 'your_first')
#
# This see will create the step_features and support directories
# each with some minimal starter files to get up moving quickly.
#
#--
# TODO: add starter cucumber.yaml config file
# TODO: Perhaps add automatic detection of location of features?
#++

argument :feature #, :default => 'new'
argument :directory

let :directory, 'features'  # TODO: way to make this argument() option?

abort "feature name is required" unless data.feature

if (output + data.directory).exist?
  copy "___feature___.feature", data.directory, :from=>'features'
else
  copy "**/*", data.directory, :from=>'features'
end

#select :setup do
#  argument :directory, :default=>'features'
#  copy "**/*", data.directory, :from=>'features'
#end

