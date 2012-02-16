require 'facets/hash/weave'

module Quarry
  class Template
    class Script

      # The Commit class does the actual writing to disk for the copy script.
      # This provides a level of controllable transaction to the rendering
      # process.
      #
      class Commit

        #
        # Initialize new Commit instance.
        #
        # @param [Script] The copy script being committed.
        #
        def initialize(script)
          @script = script
        end

        #
        # The copy script instance.
        #
        # @return [Copyscript]
        #
        attr :script

        #
        def template
          script.template
        end

        #
        def metadata
          script.metadata
        end

        # 
        def commit!
          script.transactions.each do |message|
            __send__(*message)
          end
        end

        #
        # Make directory. This will auto-create subdirecties,
        # equivalent to `mkdir -p`.
        #
        def mkdir(dir)
          fileutils.mkdir_p(dir) unless File.directory?(dir)
        end

        #
        # Merge data files together.
        #
        # IMPORTANT! This currently only supports YAML files.
        #
        def merge(src, dest, opts={})
          from = template.path + src
          dest = fill_in_the_blanks(dest)

          if File.exist?(dest)  # it's already bee merged once
            data1 = YAML.load_file(dest)
          else
            orig = output + dest
            if orig.exist?
              data1 = YAML.load_file(orig)
            else
              data1 = {}
            end
          end

          if erb?(from, opts)
            dest  = dest.chomp('.erb')
            data2 = YAML.load_file(erb(from))
          else
            data2 = YAML.load_file(from)
          end

          data = hash_merge(data1, data2)
          text = data.to_yaml

          write(dest, text, opts)
        end

        #
        # Append template +src+ to the end of +dest+ file.
        #
        def append(src, dest, opts={})
          from = template.path + src
          dest = fill_in_the_blanks(dest)
          text = File.read(from)

          opts[:source] = output + dest

          append_text(dest, text, opts)

          #if File.exist?(dest)  # an appending has already occured
          #  File.open(dest, 'a'){ |f| f << text }
          #else # c.o.w. procedure
          #  orig = output + dest
          #  if orig.exist?
          #    mkdir(File.dirname(dest))
          #    fileutils.cp(orig, dest)
          #    File.open(dest, 'a'){ |f| f << text }
          #  elsif opts[:force]
          #    mkdir(File.dirname(dest))
          #    File.open(dest, 'w'){ |f| f << text }
          #  end
          #end
        end

        #
        # Copy mine file(s). Except for specially recognized files (.png, .jpg, etc.)
        # all files will be run thru the template renderer and rendered according to
        # the extension of the file. The extension `.verbatim` can be used to prevent
        # this and instead copy the file verbatim. Or a specific render format can
        # be specified via +:render+, which will be used instead.
        #
        # @param [String,Array] src
        #   File to copy relative to +:from+.
        #
        # @param [String] dest
        #   Destination directory relative to +output+.
        #
        # @param [Hash] options
        #   Copy options.
        #
        # @option options [String] :from
        #   Directory of templates relative to +mine.directory+.
        #
        # @option options [String] :mode
        #   File permission mode to apply to file once copied.
        #
        def copy(src, dest, opts={})
          from = template.path + src
          dest = fill_in_the_blanks(dest)
          if from.directory?
            mkdir(dest)
          else
            if erb?(from, opts)
              dest = dest.chomp('.erb')
              text = erb(from)
            else
              text = File.read(from)
            end
            write(dest, text, opts)
          end
        end

        # TODO: Does render functionality really need to be supported?

        #
        # Same as copy but render the file through format filter(s).
        #
        # This method uses the Malt library for rendering.
        #
        def render(src, dest, opts={})
          require 'malt'

          from = template.path + src
          dest = fill_in_the_blanks(dest)
          if from.directory?
            mkdir(dest)
          else
            if erb?(from, opts)
              dest = dest.chomp('.erb')
              text = erb(from)
            else
              text = File.read(from)
            end

            fmt = opts[:type] || File.extname(from)
            if Malt.engine?(fmt)
              text = Malt.text(text, :type=>fmt)
              # chomp extension from destination
              dest = dest.chomp(File.extname(from)) unless opts[:type]
            end

            write(dest, text, opts)
          end
        end

      private

        #
        # Is a given file an ERB template?
        #
        def erb?(file, opts={})
          return true if opts[:erb]
          case File.extname(file)
          when '.erb'
            true
          else
            false
          end
        end

        # QUESTION: Do we need a new ERB context every time?

        #
        #
        #
        def erb(file)
          scope = Context.new(script).to_binding
          text  = File.read(file)
          ERB.new(text).result(scope)
        end

        #
        #def malt(file, ext)
        #  require 'malt'
        #  data = Context.new(self).to_binding
        #  ext  = ext.to_s.sub(/^\./, '')  # FIXME Malt should handle this
        #  Malt.render(:file=>file.to_s, :scope=>data, :type=>ext)
        #end

        #
        # File names can have `[name]` style variables to
        # be filed in by metadata. This method handles the
        # substituion.
        #
        def fill_in_the_blanks(string)
          string.gsub(/\[(.*?)\]/) do |match|
            metadata[$1]
          end
        end

        #
        #def transaction(&block)
        #  Transaction.new(self, &block).commit!
        #end

        #
        # Write `text` to a `file`.
        #
        def write(file, text, opts={})
          # make sure we have the directory to write into
          mkdir(File.dirname(file))
          # write the file
          File.open(file, 'w'){ |f| f << text.to_s }
          # change the mode if option given
          File.chmod(opts[:mode], file) if opts[:mode]
          # return the file name
          file
        end

        #
        # Append +text+ to the end of a +file+.
        #
        def append_text(file, text, opts={})
          if not File.exist?(file)
            return nil unless opts[:force]
            mkdir(File.dirname(file))
            if opts[:source]
              fileutils.cp(source, file)
            else
              write(file, '')
            end
          end
          # append text to file
          File.open(file, 'a'){ |f| f << text.to_s }
          # change the mode if option given
          File.chmod(opts[:mode], file) if opts[:mode]
        end

        #
        # 
        #
        def hash_merge(into, data)
          into.weave(data)
        end

        #
        # @todo Support DRYRUN mode (?)
        #
        def fileutils
          $DEBUG ? FileUtils::Verbose : FileUtils
        end

      end

    end

  end

end




=begin
        options = Hash===args.last ? args.pop : {}
        files, to, _ = *args

        raise ArgumentError if files && options[:files]
        raise ArgumentError if to    && options[:to]

        files   = files || options.delete(:files) || '**/*'
        to      = to    || options.delete(:to)
        from    = options.delete(:from)

        dir = mine.directory
        dir = from ? dir + from : dir

        list = []

        [files].flatten.each do |fmatch|
          dir.glob_relative(fmatch).each do |f|
            next if f.basename.to_s == ".mine"
            list << [(from ? File.join(from, f) : f.to_s), f.to_s]
            #list << [f.to_s, f.to_s]
          end
        end

        if to
          list.map!{ |src, dest| [src, File.join(to,dest)] }
        end

        list.each do |src, dest|
          render(src, dest, options)
        end
      end
=end

=begin
      # Copy a template file or a glob of template files. Except for specially
      # recognized files (.png, .jpg, etc.) all files will be run thru ERB.
      # The extension `.verbatim` can be used to prevent this and instead copied
      # verbatim --e.g. `foo.erb.verbatim` will result in `foo.erb`.
      def cp(from, to=nil, opts={})
        opts, to = to, nil if Hash===to

        tmpl = mine.directory

        list = []

        if from.index('//')
          d, f = *file.split('//')
          (tmpl + d).glob_relative(f).each do |x|
            list << [File.join(d, x), x.to_s]
          end
        else
          tmpl.glob_relative(from).each do |x|
            list << [x.to_s, x.to_s]
          end
        end

        if to
          list.map{ |from, fname| [from, File.join(to,fname)] }
        end

        list.each do |from, fname|
          template(from, fname, opts)
        end
      end
=end

