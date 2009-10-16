#!/usr/bin/env ruby

# Takes one argument which can either be the class name
# of the test or an equivalent pathname.

about "Generate a new test/unit skeleton."

usage "--testunit=<testname>"

argument :name, 'test file or class name' do |name|
  abort "No test name given." unless name
  abort "Test name must ba a single word" if name =~ /\s+/
  metadata.class_name = name.modulize
  metadata.test_name  = name.pathize
end

scaffold do
  test_dir = Dir['{test/unit,test}/'].first || 'test/'
  form_dir = Dir['{form{,s}/'].first || 'form/'

  copy "test/test_template.rb", "#{test_dir}test_#{metadata.test_name}.rb"
  copy "form/testunit", "#{form_dir}testunit", :chmod => 0755
end

