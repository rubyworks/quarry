require 'tmpdir'
require 'sow/core_ext'
require 'sow/manager'
require 'sow/seed'
require 'sow/copy_script'

module Sow

  # The Sower class is used to "sow" one or more seeds to a destination
  # directory.
  #
  class Sower

    # ## ARGUMENTS
    #
    #   * `seeds`:
    #     An array of seed parameters, `[[name, pick, args, data], ...]`,
    #     for creating seeds, as would be given on the command line.
    #
    # ## OPTIONS
    #
    #   * `output`:
    #     The output directory for the seed(s).
    #
    def initialize(seeds, options)
      @seeds   = initialize_seeds(seeds)
      @options = options

      @options[:output] ||= Dir.pwd
      @options[:stage]  ||= stage  # FIXME ?
    end

    #
    def initialize_seeds(seeds)
      seeds.map do |(uri, args, data)|
        uri  = Sow.fetch_seed(uri) if url?(uri)
        seed = Sow.find_seed(uri)
        [seed, args, data]
      end
    end

    #
    #
    #
    def url?(uri)
      /\w+\:\/\// =~ uri
    end

    # sow! -- Sow those seeds! 
    # ========================
    #
    # ## SYNOPSIS
    #
    # Take a set of `seeds` and `options`, generate the staging ground
    # for the seeds and then copy it to the destination.
    #
    def sow!
      report_startup
      setup_stage
      stage_seeds
      managed_copy
      remove_stage
      report_complete
    end

    #
    def stage_seeds
      seeds.each do |(seed, args, data)|
        CopyScript.run(seed, args, data, options)
      end
    end

#    #
#    #def parse_index(index)
#    #  seed, pick = index.split(':')
#    #  pick = 'default' if pick.nil?
#    #  return seed, pick
#    #end
#
#    # Add a seed to be sowen.
#    #def seed(name, *args)
#    #  @seeds << Seed.new(name, *args)
#    #end

    # Seeds to germinate.
    def seeds
      @seeds
    end

    #
    def options
      @options
    end

    # Job name.
    def job
      seeds.map{ |seed| seed.first }.join(',')
    end

    # Temporary staging directory.
    def stage
      @stage ||= (
        name = File.basename(output).chomp('/')
        time = Time.now.to_i
        Dir.tmpdir + "/sow/stage/#{name}/#{time}"
      )
    end

    # Output directory.
    def output
      @options[:output]
    end

    #alias_method :destination, :output

    #
    def quiet?
      options[:quiet]
    end

    #
    def mode
      options[:mode]
    end

    #
    #def config
    #  @config
    #end

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
    # Find a seed location by +name+.
    #
    def find(name)
      manager.find_seed(name)
    end

    #
    # Reterun an instance of a seed manager.
    #
    def manager
      @manager ||= Manager.new
    end

  end

end
