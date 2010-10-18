require 'sow/cli/abstract'

module Sow::CLI

  #
  class Init < Abstract

    command 'seed init'

    #
    def call(argv)
      output = options.output || Dir.pwd
      Sow.init(output)
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: sow init"
        o.on('--output', '-o PATH'){ |path| options.output = path }
      end
    end

  end

end

