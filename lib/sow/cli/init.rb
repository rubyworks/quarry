require 'sow/cli/abstract'

module Sow::CLI

  class Init < Abstract

    #
    def call(argv)
      FileUtils.mkdir('.sow')
    end

    #
    def opts
      super
    end

  end

end

