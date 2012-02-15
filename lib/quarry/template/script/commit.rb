module Quarry
  class Template
    class Script

      # The Commit class does the actual writing to disk for the Copyscript.
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
        # Append +text+ to the end of a +file+.
        #
        def append(file, text)
          if File.exist?(file)
            File.open(file, 'a'){ |f| f << text.to_s }
          else # c.o.w. procedure
            src = output + file
            if src.exist?
              mkdir(File.dirname(file))
              fileutils.cp(src, file)
              File.open(file, 'a'){ |f| f << text.to_s }
            end
          end
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
          render(src, dest, opts)
        end

        #
        # Copy template file to +dest+ with +mode+.
        # Or create template directory as +dest+ with +mode+.
        #
        # This method uses Malt to render the template.
        #
        def render(src, dest, opts={})
          mode = opts[:mode]
          from = template.path + src
          dest = fill_in_the_blanks(dest)
          if from.directory?
            mkdir(dest)
          else
            if erb?(dest, opts)
              #if ext = opts[:render]
              #  if Malt.engine?(ext)
              #    result = malt(from, ext)
              #    dest = dest.chomp(File.extname(from)) # TODO: what about rhtml -> html, etc ?
              #  end
              #else
              #  result = File.read(from)
              #end
              dest   = dest.chomp('.erb')
              result = erb(from)
              parent = File.dirname(dest)
              mkdir(parent)
              File.open(dest, 'w'){|f| f << result.to_s}
              fileutils.chmod(mode, dest) if mode
            else
              iopts  = mode ? {:mode=>mode} : {}
              parent = File.dirname(dest)
              mkdir(parent)
              fileutils.install(from, dest, iopts)
            end
          end
        end

      private

        #
        # Should a given file be processed as a template (via ERB).
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

        # TODO: Do we need a new context every time?

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

