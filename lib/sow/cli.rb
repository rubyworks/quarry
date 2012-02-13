#require 'sow/sower'
require 'ostruct'

module Sow

  #
  module CLI

    # Entry point for commandline interface.
    def self.run(*argv)
      argv.shift if argv.first == '-'
      argv << 'help' if argv.empty?

      cls, argv = parse(argv)

      if $DEBUG
        cls.run(*argv)
      else
        begin
          cls.run(*argv)
        rescue => error
          $stderr << error.to_s + "\n"
          $stderr.puts error.backtrace
        end
      end
    end

    # TODO: This could be used instead, but it's awfully complex.
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

  end

end

# load command subclasses
Dir[File.dirname(__FILE__) + '/cli/*'].each do |file|
  require file
end

