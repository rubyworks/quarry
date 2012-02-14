require 'quarry/cli/abstract'

module Quarry::CLI

  # Update a scm-based mine.
  #
  class Update < Abstract

    command 'update'

    #
    def call(argv)
      if trial?
        $stderr.puts("Dryrun: cd #{path}; scm #{pull}")
      else
        name = argv.first
        manager.update(name)
      end
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: quarry update [name]"
      end
    end

  end

end

