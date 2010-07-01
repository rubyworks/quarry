require 'fcntl'
require 'facets/string/tabto'

        opts.on('--extend', '-x', 'output copylist') do
          @action = :print
        end


    # If an optional copylist is padded in via a stdin or a pipe.
    def extended_copylist
      list = []
      if STDIN.fcntl(Fcntl::F_GETFL, 0) == 0
        val = STDIN.read
        if !val.empty?
          list = YAML.load(val)
        end
      end
      list
    end

