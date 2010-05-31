require 'reap/reapfile'

module Sow

  # A Sowfile is an extended Reapfile.
  class Sowfile < Reap::Reapfile

    #
    def initialize(scaffold, file)
      @scaffold = scaffold
      super(scaffold, file)
    end

    # Give a one line usage template, e.g. '--ruby=<name>'
    # "Usage: sow" is automatically prefixed to this.
    def about(description)
      @scaffold.about = description
    end

    # Give a one line usage template, e.g. '--ruby=<name>'
    # "Usage: sow" is automatically prefixed to this.
    def usage(usage)
      @scaffold.usage = usage
    end

    # Define the commandline argument.
    def argument(name, desc=nil, &valid)
      @scaffold.arguments << [name, desc, valid]
    end

    # Access to scaffold's files.
    def source
      @scaffold.source
    end

    # Access to destination's files.
    def destination
      @scaffold.destination
    end

    # Schedule a copy operation from source file to destination path.
    def copy(from, path=nil)
      @scaffold.copylist << [from, path]
    end

    # Schedule a template rendering, to be save to destination path and using local options.
    def render(from, *path_local)
      local = (Hash === path_local.last ? path_local.pop : {})
      path  = path_local.first
      @scaffold.renderings << [from, path, local]
    end

    # Schedule a file modification.
    def modify(path, &block)
      @scaffold.modifications << [path, block]
    end

    # Schedule a file deletion.
    def delete(path)
      @scaffold.deletions << path
    end

  end

end

