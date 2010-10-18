require 'tmpdir'
require 'sow/seed'
require 'sow/sower_eval'

module Sow

  # The Sower class is used to "sow" one or more seeds to a destination
  # directory.
  #
  class Sower

    # ## ARGUMENTS
    #
    #   * `seeds`:
    #     An Array of Seed objects, or an Array of seed parameters
    #     for creating seeds, i.e. `[[name, args, data]...]`.
    #
    # ## OPTIONS
    #
    #   * `output`:
    #     The output directory for the seed(s).
    #
    def initialize(seeds, options)
      @seeds   = seeds.map{ |seed| Seed === seed ? seed : Seed.new(*seed) }
      @options = options
      @options[:output] ||= Dir.pwd
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
      seeds.each do |seed|
        seeder = SowerEval.new(seed, options)
        seeder.sow!(stage)
      end
      managed_copy
      remove_stage
      report_complete
    end

    ## Add a seed to be sowen.
    ##def seed(name, *args)
    ##  @seeds << Seed.new(name, *args)
    ##end

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
      seeds.map{ |seed| seed.name }.join(',')
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
    def quiet? ; options[:quiet] ; end

    #
    def mode   ; options[:mode]  ; end

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

    # Output to provide on startup of generation.
    def report_startup
      @time = Time.now
      #dir = File.basename(source) #File.basename(File.dirname(source))
      report "Generating #{job} in #{File.basename(output)}:\n\n"
    end

    # Output to provide when generation is complete.
    def report_complete
      report "\nFinished in %.3f seconds." % [Time.now - @time]
    end

    #
    def report(message)
      puts message unless options[:quiet] or options[:trial]
    end

    MARKER = /___.*?___/

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

    # Grep each file in +files+ for occurance of +marker+.
    #
    # files  - array of file names to check
    # marker - the Regexp to search for
    #
    # Returns an Array of file names containing the marker.
    def check_for_fixes(files, marker)
      marker ||= MARKER
      list = []
      files.each do |file|
        next if File.directory?(file)
        File.open(file) do |f|
          f.grep(marker){ |l| list << file }
        end
      end
      list.uniq
    end

  end

end
