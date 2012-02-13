require 'sow/cli/abstract'

module Sow::CLI

  # Update a scm-based seed.
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
        o.banner = "Usage: sow update [name]"
      end
    end

  end

end

