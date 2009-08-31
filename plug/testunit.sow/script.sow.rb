#!/usr/bin/env ruby

# Takes one argument which can either be the class name
# of the test or an equivalent pathname.

help "Generate a new test/unit skeleton."

usage "testunit [options] <test>"

argument :name, 'test file or class name' do
  abort "No test name given." unless name
  abort "Test name must ba a single word" if name =~ /\s+/
  metadata.class_name = name.modulize
  metadata.test_name  = name.pathize
end

manifest do
  copy "test.rb", "test/test_#{metadata.test_name}.rb" #, 
  #  :test_name  => name.pathize,
  #  :class_name => name.modulize
end

