require 'sow/cli/abstract'

module Sow::CLI

  #
  class Init < Abstract

    #
    def call(argv)
      output = options.output || Dir.pwd
      FileUtils.mkdir_p(File.join(output, '.sow'))
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

