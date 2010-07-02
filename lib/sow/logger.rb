module Sow

  # The Logger class routes output to the console.
  #
  class Logger

    #
    attr :copier

    #
    def initialize(copier)
      @copier = copier
    end

    # If there is nothing to generate this will be called
    # to display a message to the effect.
    def report_nothing_to_generate
      report "Nothing to generate."
    end

    # Output to provide on startup of generation.
    def report_startup(source, output) # FIXME: pass what info?
      @time = Time.now
      dir = File.basename(source) #File.basename(File.dirname(source))
      report "Generating #{dir} in #{File.basename(output)}:\n\n"
    end

    # Output to provide when generation is complete.
    def report_complete
      report "\nFinished in %.3f seconds." % [Time.now - @time]
    end

    # Output to provide as generation is progressing.
    def report_create(file, how, atime)
      report "%10s [%.4fs] %s" % [how, (Time.now - atime), file]
    end

    MARKER = /__.*?__/

    # Use this to report any "templating" that needs to done by hand.
    #
    # files  - array of file names to check
    # marker - the Regexp to search for
    #
    def report_fixes(files, marker=nil)
      glist = check_for_fixes(files, marker)
      unless glist.empty?
        puts "\nYou need to fix the occurances of missing information in the following files:\n\n"
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

    #
    def newline
      puts
    end

    #
    def report(message)
      puts message unless copier.quiet? or copier.trial?
    end

  end

end

