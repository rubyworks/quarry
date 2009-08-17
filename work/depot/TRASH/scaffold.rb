require 'sow/generator'

module Sow

  # Base class for Scaffolding Generators, ie. generators
  # that are used to create entire new project layouts.
  #
  # Scaffolds generally use the arguments for subselection
  # of scaffolding.
  #--
  # and any options as supplements to metadata.
  #++
  #
  class Scaffold < Generator

    def scaffold? ; true ; end

    #
    #def setup(args=[], opts={})
    #  name = args.shift
    #
    #  #metadata.name = naae || directory.basename.to_s.methodize
    #  raise "Missing argument for project name." unless name
    #
    #  metadata.name = name
    #
    #  super(args, opts)
    #end

    #
    def confirm_generate?
      return true if new?
      return true if force?
      return true if safe?
      #return true if !arguments.empty?  # there are specific selections
      if !directory.empty?
        abort "Project isn't empty. Use --force, --skip or --safe to override."
      end
    end

    ### Output to provide on startup of generation.
    def report_startup
      @time = Time.now
      dir = File.basename(File.dirname(source))
      report "Scaffolding #{File.basename(Dir.pwd)}/ with #{dir} templates...\n\n"
    end

    #
    #def report_complete
    #  super
    #  report_fixes
    #end

  end

end

