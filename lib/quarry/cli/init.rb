require 'quarry/cli/abstract'

module Quarry::CLI

  #
  class Init < Abstract

    command 'init'

    #
    def call(argv)
      output = options.output || Dir.pwd
      Quarry.init(output)
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: quarry init"
        o.on('--output', '-o PATH'){ |path| options.output = path }
      end
    end

  end

end

