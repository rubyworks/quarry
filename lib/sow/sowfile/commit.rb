module Sow

  class Sowfile

    #
    class Commit

      #
      # @param [Sowfile]
      #
      def initialize(sowfile)
        @sowfile = sowfile
      end

      # The Sowfile.
      #
      # @return [Sowfile]
      attr :sowfile

      #
      def seed
        sowfile.seed
      end

      #
      def metadata
        sowfile.metadata
      end

      # 
      def commit!
        sowfile.transactions.each do |message|
          __send__(*message)
        end
      end

      # Make directory. This will auto-create subdirecties,
      # equivalent to `mkdir -p`.
      def mkdir(dir)
        fileutils.mkdir_p(dir) unless File.directory?(dir)
      end

      # Append +text+ to the end of a +file+.
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

      # Copy seed file(s). Except for specially recognized files (.png, .jpg, etc.)
      # all files will be run thru the template renderer and rendered according to
      # the extension of the file. The extension `.verbatim` can be used to prevent
      # this and instead copy the file verbatim. Or a specific render format can
      # be specified via +:render+, which will be used instead.
      #
      # == ARGUMENTS
      #
      # `files`:
      # Glob pattern or an array of patterns of file names relative to +from+.
      #
      # `to`:
      # Destination directory relative to +output+.
      #
      # == OPTIONS
      #
      # `from => <dir>`:
      # Directory of templates relative to +seed.directory+.
      #
      # `:files => <glob>`:
      # Glob pattern or an array of patterns of file names relative to +from+.
      #
      # `:to => <dir>`:
      # Destination directory relative to +output+.
      #
      # `:render => <format>`:
      # Format to render file as before saving. Defaults to file's extension name,
      # if recognized. Otherwise `verbatim`.
      #
      def copy(src, dest, opts={})
        render(src, dest, opts)
      end

=begin
        options = Hash===args.last ? args.pop : {}
        files, to, _ = *args

        raise ArgumentError if files && options[:files]
        raise ArgumentError if to    && options[:to]

        files   = files || options.delete(:files) || '**/*'
        to      = to    || options.delete(:to)
        from    = options.delete(:from)

        dir = seed.directory
        dir = from ? dir + from : dir

        list = []

        [files].flatten.each do |fmatch|
          dir.glob_relative(fmatch).each do |f|
            next if f.basename.to_s == "Sowfile"
            next if f.basename.to_s == "_Sowfile"
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

        tmpl = seed.directory

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

      # Copy template file to +dest+ with +mode+.
      # Or create template directory as +dest+ with +mode+.
      #
      # This method uses Malt to render the template.
      def render(src, dest, opts={})
        mode = opts[:mode]
        from = seed.directory + src
        dest = fill_in_the_blanks(dest)
        if from.directory?
          mkdir(dest)
        else
          if verbatim?(dest, opts)
            dest   = dest.chomp('.verbatim')
            iopts  = mode ? {:mode=>mode} : {}
            parent = File.dirname(dest)
            mkdir(parent)
            fileutils.install(from, dest, iopts)
          else
            ext = (opts[:render] || File.extname(from)).to_s
            if Malt.engine?(ext)
              result = engine_render(from, ext)
              dest   = dest.chomp(File.extname(from)) # TODO: what about rhtml -> html, etc ?
            else
              result = File.read(from)
            end
            parent = File.dirname(dest)
            mkdir(parent)
            File.open(dest, 'w'){|f| f << result.to_s}
            fileutils.chmod(mode, dest) if mode
          end
        end
      end

    private

      # TODO: Do we need a new context every time?

      #
      def engine_render(file, ext)
        data = Context.new(self).to_binding
        #ERB.new(text).result(context)
        #data = metadata.data
        ext  = ext.to_s.sub(/^\./, '')  # FIXME Malt should handle this
        Malt.render(:file=>file.to_s, :scope=>data, :type=>ext)
      end

      #
      VERBATIM_EXTENSIONS = %w{.jpg .png .gif .pdf .ogv .ogg}

      # Should a given file be processed as a template (via ERB).
      def verbatim?(file, opts={})
        return true if opts[:verbatim]
        return true if opts[:render].to_s == 'verbatim'
        case File.extname(file)
        when '.verbatim'
          true
        when *VERBATIM_EXTENSIONS
          true
        else
          false
        end
      end

      # File names can have __name__ style variables to
      # be filed in by metadata. This method handles the
      # substituion.
      def fill_in_the_blanks(string)
        string.gsub(/__(.*?)__/) do |match|
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
