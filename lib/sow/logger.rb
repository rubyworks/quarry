module Sow

  # The Logger class routes output to the console.
  #
  class Logger

    #
    attr :generator

    #
    def initialize(generator)
      @generator = generator
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

    # Use this to report any "templating" that needs
    # to done by hand.
    def report_fixes(marker='FIXME:')
      glist = check_for_fixes(marker)
      unless glist.empty?
        puts "\nYou need to fix the occurances of '#{marker}' in the following files:\n\n"
        glist.each do |file|
          puts "      #{file}"
        end
        puts
      end
    end

    # TODO: don't use grep
    def check_for_fixes(marker)
      g = `grep -R #{marker} .` # FIXME Use ruby code instead
      glist = []
      g.each_line do |line|
        line = line.gsub('./','')
        indx = line.index(':')
        file, *desc = *line.split(':')
        glist << file
      end
      glist.uniq
    end

  private

    def report(message)
      puts message unless generator.quiet? or generator.trial?
    end

  end

end

