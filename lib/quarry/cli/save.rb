require 'quarry/cli/abstract'

module Quarry::CLI

  class Save < Abstract

    command 'save'

    #
    def call(argv)
      Quarry.save(*argv)
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: quarry save <name> [file ...]"
        o.separator "Save directory/files to named mine."
      end
    end

  end

end

