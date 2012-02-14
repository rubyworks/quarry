module Quarry

  class Template

    # The Template::Management module extends the Template module
    # providing it class methods for wokring with templates.
    #
    module Management

      #def self.load(name)
      #  path = find(name)
      #  raise "No mine -- #{name}" unless path
      #  new(path)
      #end

      #
      # Cached list of all available templates.
      #
      # @return [Array<Template::Directory>] Template list
      #
      def templates
        @templates ||= (
          list = []
          list.concat templates_from_project
          list.concat templates_from_remotes
          list.concat templates_from_plugins
          list
        )
      end

      #
      # Sorted list of template names.
      #
      # @return [Array] Sorted template names.
      #
      def list
        templates.map{ |t| t.name }.sort_by{ |a|
          i = a.index('@')
          i ? [a[i+1..-1], a] : [a, a]
        }
      end

      #
      # Find template given it's name, or first unique portion of it's name.
      #
      # @return [Template::Directory]
      #
      # @raise [MissingTemplate]
      #
      # @raise [DuplicateTemplate]
      #
      def find(match)
        hits = search(match)
        raise(MissingTemplate, "No matching templates.") if hits.size == 0
        if hits.size > 1
          message = "More than one match:\n  " + hits.map{|name, dir| name}.join("\n  ")
          raise(DuplicateTemplate, message)
        end
        hits.first
      end

      #
      # Search for templates by name.
      #
      def search(match)
        hits = templates.select do |mine|
          match == mine.name
        end
        if hits.size == 0
          hits = templates.select do |ore|
            /^#{match}/ =~ mine.name
          end
        end
        return hits
      end

      #
      # Clone template repository.
      #
      # @raise [DuplicateTemplate]
      #   If a template by the given name already exists.
      #
      def clone(uri, options={})
        name  = options[:name] || uri_to_name(uri)
        dir   = bank_folder
        out   = dir + name

        if File.exist?(out)
          raise DuplicateTemplate, "template already saved with that name -- #{name}"
        end

        # TODO: handle dryrun by using special File/URI interfance?
        if url?(uri)
          SCM.clone(uri, :dest=>out)
        else
          FileUtils.mkdir_p(dir)
          Dir.chdir(dir) do
            FileUtils.symlink(uri, name) #`ln -s #{uri} #{name}`
          end
        end

        return name
      end

      #
      # Remove a template by name.
      #
      # Careful! This method deletes files with force.
      #
      def remove(name)
        template = find(name)
        shell.rm_rf(template.path) if template
      end

      #
      # Since templates are usually version controlled repositories, they
      # should be updated from time to time.
      #
      def update(name=nil)
        if name
          template = find(name)
          template.update
        else
          list.each do |template|
            template.update
          end
        end
      end

      #
      # Save contents of source folder to the named template in one's personal
      # collection.
      #
      # FIXME: This needs to be more robust.
      #
      def save(name, src=nil)
        raise ArgumentError, "template name not given" unless name

        src = src || Dir.pwd
        dir = Quarry.bank_folder + "#{name}"  # silo_folder
        copier = Copier.new(src, dir, :backup=>false)
        copier.copy
        copyfile = dir + '.ore/copy.rb'
        if !copyfile.exist?
          File.open(copyfile, 'w'){ |f| f << 'copy all' }
        end
        dir
      end

      #
      # Lookup ore and return the contents of it's README file.
      # If it does not have a README file that it will return a
      # message cveying as much. If the ore is not found it 
      # raise an error.
      #
      def help(name)
        if template = find(name)
          template.help
        else
          raise "No matching template."
        end
      end

    private

      #
      # Collect templates from present working project.
      #
      def templates_from_project
        # project directory  (TODO: locate project root ?)
        dirs = Quarry.work_folder.glob("quarry/*/")
        dirs = dirs.map{ |d| d.expand_path }  # clears off the trialing '/'
        dirs.each do |dir|
          ore = Template::Directory.new(dir, :type=>'work')
          list << ore
        end
      end

      # TODO: Should remote templates and personal templates 
      # be stored in separate locations?

      # personal silo
      #def templates_from_saves
      #  dirs = silo_folder.glob("*")
      #  dirs = dirs.map{ |d| d.parent }
      #  dirs.each do |dir|
      #    ore = Template::Directory.new(dir, :type=>'silo')
      #    list << ore
      #  end
      #end

      #
      # Collect templates from $QUARRY_HOME (`$HOME/.quarry`).
      # These are either templates cloned from remote repository
      # or local templates saved by user.
      #
      def templates_from_remotes
        list = []
        dirs = Quarry.bank_folder.glob("*/")
        dirs = dirs.map{ |d| d.expand_path }  # clears off the trialing '/'
        dirs.each do |dir|
          ore = Template.new(dir, :type=>'bank')
          list << ore
        end
        list
      end

      #
      # Collect templates from packages installs.
      #
      def templates_from_plugins
        list = []
        dirs = ::Find.data_path("quarry/**/#{CONFIG_FILE}")
        dirs = dirs.uniq.map{ |d| File.dirname(d) }
        dirs.each do |dir|
          ore = Template.new(dir, :type=>'plugin')
          list << ore
        end
        list
      end

      #
      # Helper method to determine if a URI is a local file path or a remote URI.
      #
      def url?(uri)
        /\w+\:\/\// =~ uri
      end

      #
      # Convert an URI into a suitable directory name for storing banks.
      #
      def uri_to_name(uri)
        uri = URI.parse(uri)
        path = uri.path
        path = path.chomp(File.extname(path))
        #File.join(uri.host,path).split('/').reverse.join('.')
        path.split('/').reverse.join('.')
      end

      #
      #def path_to_name(path)
      #  div   = path.to_s.split('/') # File::SEPARATOR ?
      #  div.pop if div.last == 'default'
      #  name = div.reverse.join('.').chomp('.')
      #  return name, namespace
      #end

      #
      # Interface to FileUtils or FileUtils::DryRun.
      #
      def shell
        $DRYRUN ? FileUtils::DryRun : FileUtils
      end

    end

    # Extend Template with Management functions.
    extend Management
  end

end
