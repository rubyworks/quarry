# TODO: ArgVector will become Shellwords extension in future.
require 'facets/argvector'

module Sow

  # sow ruby --name=myapp --author='Tommy' myapp/
  #
  #
  class Command

    def initialize
    end

    def execute(argv=ARGV)
      argv = argv.dup

      uri = argv.find{ |a| /^\-/ !~ a }
      argv.delete_at(argv.index(uri))

      #if /^\-/ !~ argv.last
      

      source = get_scaffold(uri)

      scaffold = Scaffold.new(source, destination)

      session

      scaffold.run

      destination
      options =

    end

    #
    def get_scaffold(uri)
      case uri
      when /^git:/
        source = File.join(Dir.tmpdir, 'sow', File.basename(uri))
        `git clone #{uri} #{source}`
      when /^svn:/
        source = File.join(Dir.tmpdir, 'sow', File.basename(uri))
        `svn checkout clone #{uri} #{source}`
      else
        source = Plugin.find(File.join('sow', uri))
      end
      source
    end

  end

end
