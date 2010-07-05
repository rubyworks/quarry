require 'sow/generator'
require 'ostruct'

module Sow

  #
  module CLI

    # Entry point for commandline interface.
    def self.run(*argv)
      argv.shift if argv.first == '-'

      argv << 'help' if argv.empty?

      cmd = argv.shift

      cmdc = (
        case cmd
        when 'help', '-h', '--help'
          CLI::Help
        when 'bank'
          case cmd = argv.shift
          when 'install'   then CLI::BankInstall
          when 'uninstall' then CLI::BankUninstall
          when 'update'    then CLI::BankUpdate
          else
            argv.unshift(cmd) if cmd
            CLI::BankList
          end
        when 'seed', 'list'
          case cmd = argv.shift
          when 'save'           then CLI::SeedSave
          when 'remove', 'rm'   then CLI::SeedRemove
          else
            argv.unshift(cmd) if cmd
            CLI::SeedList
          end
        when 'init' then CLI::Init
        when 'new'  then CLI::New
        when 'gen'  then CLI::Gen
        when 'undo' then CLI::Undo
        when 'copy' then CLI::Copy
        else
          argv.unshift(cmd) if argv
          CLI::Gen
        end
      )

      if $DEBUG
        cmdc.run(*argv)
      else
        begin
          cmdc.run(*argv)
        rescue => error
          $stderr << error.to_s + "\n"
        end
      end
    end

    # TODO: This could be used instead, but it's awfully complex.
    def self.parse(argv)
      lookup = registry.map{ |cc| [cc, cc.cli] }.sort{ |a,b| b[1].size <=> a[1].size }
      x = lookup.find do |cc, cli|
        t = true
        cli.each_with_index do |r, i|
          t = t && (r === argv[i])
        end
        t
      end
      cmdc = x[0]
      argv = argv[x[1].size..-1]
    end

  end

end

require 'sow/cli/abstract'

require 'sow/cli/new'
require 'sow/cli/gen'
require 'sow/cli/undo'
require 'sow/cli/copy'

require 'sow/cli/bank_list'
require 'sow/cli/bank_install'
require 'sow/cli/bank_update'
require 'sow/cli/bank_uninstall'

require 'sow/cli/seed_list'
require 'sow/cli/seed_save'
require 'sow/cli/seed_remove'

require 'sow/cli/help'

