require 'tmpdir'
require 'quarry/core_ext'
require 'quarry/template'

module Quarry

  # You think of the Generator class as miner(s) working out the ore, i.e. it
  # renders each specified template to the desinated destination.
  #
  class Generator

    #
    # Initialize new Miner instance.
    #
    # @param [Array<Array>] operations
    #   An array of parameters, `[[uri, args, data], ...]` for creating 
    #   Mine instances.
    #
    # @options [Hash] options
    #   Mining options.
    #
    # @option options [String] :output
    #   The output directory for the operations(s).
    #
    def initialize(operations, options)
      @operations = initialize_operations(operations)
      @options    = options

      @options[:output] ||= Dir.pwd
      @options[:stage]  ||= stage  # FIXME ?
    end

    #
    #
    #
    def initialize_operations(operations)
      operations.map do |(uri, args, data)|
        uri      = Template.fetch(uri) if url?(uri)
        template = Template.find(uri)
        [template, args, data]
      end
    end

    #
    # Is a URI a remote URL, as opposed to a local name.
    #
    def url?(uri)
      /\w+\:\/\// =~ uri
    end

    #
    # Quarry that Ore! Take a set of `operations` and `options`, setup the
    # staging ground for the operations and then run copy script to render
    # files to the destination.
    #
    def run!
      report_startup
      setup_stage
      stage_operations
      managed_copy
      remove_stage
      report_complete
    end

    #
    # Collect CopyScripts for operations.
    #
    def stage_operations
      operations.each do |(tmpl, args, data)|
        #Template::Script.run(tmpl, args, data, options)
        templ.script.setup(options).call(args, data)
      end
    end

#    #
#    #def parse_index(index)
#    #  mine, pick = index.split(':')
#    #  pick = 'default' if pick.nil?
#    #  return mine, pick
#    #end
#
#    # Add a mine.
#    #def mine(name, *args)
#    #  @operations << Seed.new(name, *args)
#    #end

    # Seeds to germinate.
    def operations
      @operations
    end

    #
    def options
      @options
    end

    #
    # Job description.
    #
    # @return [Array] List of ore names joined by a comma.
    #
    def job
      operations.map{ |o| o.first }.join(',')
    end

    #
    # Temporary staging directory.
    #
    def stage
      @stage ||= (
        name = File.basename(output).chomp('/')
        time = Time.now.to_i
        Dir.tmpdir + "/quarry/stage/#{name}/#{time}"
      )
    end

    # Output directory.
    def output
      options[:output]
    end

    #alias_method :destination, :output

    #
    # Essentially, mute all standard output about operations.
    #
    def quiet?
      options[:quiet]
    end

    #
    #
    #
    def mode
      options[:mode]
    end

    #
    #def config
    #  @config
    #end

    #
    # Create the staging directory.
    #
    def setup_stage
      fu.mkdir_p(stage)
      #fu.mkdir_p(output) unless File.exist?(output)
      #fu.cp_r(output+'/.', stage)
    end

    #
    def managed_copy
      copier.copy
    end

    #
    def copier
      Copier.new(stage, output, :quiet=>quiet?, :mode=>mode)
    end

    # Remove stage directory.
    def remove_stage
      #fu.rm_r(stage) unless $DEBUG
    end

    #
    def fu
      FileUtils
    end

    #
    # Output to provide on startup of generation.
    #
    def report_startup
      @time = Time.now
      #dir = File.basename(source) #File.basename(File.dirname(source))
      report "Generating #{job} in #{File.basename(output)}:\n\n"
    end

    #
    # Output to provide when generation is complete.
    #
    def report_complete
      report "\nFinished in %.3f seconds." % [Time.now - @time]
    end

    #
    #
    #
    def report(message)
      puts message unless options[:quiet] or options[:trial]
    end

    #
    # Use this to report any "templating" that needs to done by hand.
    #
    # files  - array of file names to check
    # marker - the Regexp to search for
    #
    def report_fixes(files, marker=nil)
      glist = check_for_fixes(files, marker)
      unless glist.empty?
        puts "\nYou may need to fix the occurances of missing information in the following files:\n\n"
        glist.each do |file|
          puts "      #{file}"
        end
        puts
      end
    end

    #
    # Grep each file in +files+ for occurance of +marker+.
    #
    # files  - array of file names to check
    # marker - the Regexp to search for
    #
    # Returns an Array of file names containing the marker.
    #
    def check_for_fixes(files, marker=nil)
      marker ||= EDIT_MARKER
      list = []
      files.each do |file|
        next if File.directory?(file)
        File.open(file) do |f|
          f.grep(marker){ |l| list << file }
        end
      end
      list.uniq
    end

    #
    # Find a mine location by +name+.
    #
    def find(name)
      Template.find(name)
    end

  end

end
