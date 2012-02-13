require 'quarry/cli/abstract'

module Quarry::CLI

  # Update a scm-based mine.
  #
  class Update < Abstract

    command 'update'

    #
    def call(argv)
      name = argv.first
      manager.update(name)
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: quarry update [name]"
      end
    end

  end

end

