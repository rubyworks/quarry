require 'test/unit'  # can I load test case only?
require 'facets/kernel/silence'
require 'tmpdir'
require 'fileutils'

module Reap
module TestCases

  module CaseTestable

    FIXTURE = "test/data"
    TEMPDIR = File.join(Dir.tmpdir, 'sow', 'test')

    def setup
      FileUtils.rm_r TEMPDIR if File.exist?(TEMPDIR)
      FileUtils.mkdir_p TEMPDIR
    end

  end

end
end

