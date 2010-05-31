# Test::Unit Scaffold

module Sow::Plugins

  class TestUnit < Script

    attr_accessor :dir

    attr_accessor :name

    #
    def setup
      @dir ||= argument

      if name
        abort "Test name must ba a single word" if name =~ /\s+/

        metadata.class_name = name.modulize
        metadata.test_name  = name.pathize
      end
    end

    #
    def manifest
      test_dir = (Dir['{test/unit,test}/'].first || 'test').chomp('/')
      form_dir = (Dir['{form{,s}/'].first || 'form').chomp('/')

      test_dir = dir if dir

      copy "test"         , test_dir
      copy "form/testunit", form_dir + "/testunit", :chmod => 0755

      if name
        copy "test/test_template.rb", "#{test_dir}/test_#{metadata.test_name}.rb"
      end
    end

  end

end


