module Quarry

  # Command line interface.
  #
  module CLI

    #
    # Entry point for commandline interface.
    #
    def self.run(*argv)
      argv.shift if argv.first == '-'

      # if not command given, then display help
      # in future this might look for an "auto template"
      # in Dir.pwd first
      argv << 'help' if argv.empty?

      cls, argv = parse(argv)

      if $DEBUG
        cls.run(*argv)
      else
        begin
          cls.run(*argv)
        rescue => error
          $stderr << error.to_s + "\n"
          #$stderr.puts error.backtrace
        end
      end
    end

    #
    # Parse arguments into command class and remaining arguments.
    #
    def self.parse(argv)
      args   = argv.join(' ')
      lookup = registry.sort_by{ |cmd, cls| cmd.size }.reverse
      cmd, cls = lookup.find do |(cmd, cls)|
        args.start_with?(cmd)
      end

      size = cmd.split(/\s+/).size
      argv = argv[size..-1]

      return cls, argv
    end

    #
    # Load command subclasses.
    #
    def self.require_commands
      Dir[File.dirname(__FILE__) + '/cli/*'].each do |file|
        require file
      end
    end

  end

end

# Load command subclasses.
Quarry::CLI.require_commands

