require 'optparse'
require 'mint/copier'

module Mint

  class Command

    #
    def self.main(*argv)
      new.run(*argv)
    end

    #
    def initialize
      @options = {}
    end

    #
    def options
      @options
    end

    #
    def option_parser
      OptionParser.new do |opt|

        opt.on('--skip', 'skip all overwrites') do
          options[:skip] = true
        end

        opt.on('--force', 'force overwrites') do
          options[:force] = true
        end

        opt.on('--dryrun', 'only pretend to copy files') do
          options[:pretend] = true
        end

        opt.on('--debug' , 'provide debuggin information') do
          $VERBOSE = true
          $DEBUG = true
        end
      end
    end

    #
    def run(*argv)
      option_parser.parse!(argv)

      source, destination = *argv

      copier = Copier.new(source, destination, options)
      copier.copy
    end

  end

end
