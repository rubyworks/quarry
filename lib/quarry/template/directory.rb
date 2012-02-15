module Quarry
  class Template
    class Directory

      #
      IGNORE = [TEMPORARY_DIRECTORY, '.', '..', '.git', '.hg', '.svn', '_darcs']

      #
      def initialize(template, path)
        @template = template
        @path     = Pathname.new(path)
      end

      #
      #
      #
      attr :template

      #
      #
      #
      attr :path

      #
      #
      #
      def directoires
        read unless read?
        @directories
      end

      #
      #
      #
      def files
        read unless read?
        @files
      end

      #
      # Enumerates through the directories in the template directory.
      #
      # @yield [path]
      #   The given block will be passed each directory path.
      #
      # @yieldparam [String] path
      #   The relative path of a directory within the template directory.
      #
      def each_directory(&block)
        directories.each(&block)
      end

      #
      #
      #
      def each_file(&block)
        files.each(&block)
      end

      #
      # Directory path as string.
      #
      def to_s
        path.to_s
      end

    private

      def read?
        @read
      end

      def read
        Dir.chdir(@path) do
          read_directory('.')
        end
      end

      def read_directory(dir)
        Dir.entries(dir) do |name|
          next if IGNORE.include?(name)

          path = File.join(dir, name)

          if File.directory?(path)
            @directories << path
            read_directory(path)
          else
            @files << path
          end
        end

        @read = true
      end

    end
  end
end
