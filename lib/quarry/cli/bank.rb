require 'quarry/cli/abstract'

module Quarry::CLI

  # Clone a mine and place it into the "bank".
  #
  # TODO: Now that `mine` is used over `seed` we need to a new term for "bank".
  #
  class Bank < Abstract

    #
    command 'bank'

    #
    def call(argv)
      uri  = argv.shift
      name = argv.shift

      abort opts.to_s if argv.shift

      if trial?
        #$stderr.puts("  mkdir -p #{dir}")
        #$stderr.puts("  cd #{dir}")
        #$stderr.puts("  #{cmd}")
        $stderr.puts "Dryrun: scm clone #{uri}"
      else
        manager.clone(uri, :name=>name)
      end
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: quarry bank <uri> [name]"
      end
    end

  end

end

