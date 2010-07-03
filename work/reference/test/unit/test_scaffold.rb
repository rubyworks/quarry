require File.dirname(__FILE__) + '/helper'
require "test/unit"

module Reap
module TestCases

  class TestScaffold < Test::Unit::TestCase

    include CaseTestable

    def setup
      super
      @dirname = 'scaffold'
      @dir     = File.join(TEMPDIR, 'scaffold')
      FileUtils.rm_r(@dir) if File.exist?(@dir)
      #FileUtils.cp_r(FIXTURE + '/scaffold', @dir)
    end

    def test_scaffold
      Dir.chdir(TEMPDIR) do
        silently do
          system "sow reap #{@dirname}"
        end

        assert(File.directory?(@dirname), "did not scaffold")

        Dir.chdir(@dirname) do
          assert(File.exist?('README'), "README does not exist")
        end
      end
    end

  end

end
end

