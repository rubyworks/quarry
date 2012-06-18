require 'scm'

module Quarry

  #
  #
  #
  def self.cli(*argv)

    Shellwords.run argv,
      '--debug' => ->{ $DEBUG = true }

    uri  = argv.shift
    name = File.basename(uri).chomp(File.extname(uri))
    repo = nil

    Dir.chdir(conf_dir) do
      repo = SCM.clone(uri, :dest=>name)
    end

    location = Dir.pwd  #TODO: option for dir
    scaffold = File.join(conf_dir, name)

    template = stage(location)

    render(scaffold, template)

    merge(template, location) 
  end

  #
  #
  #
  def self.stage(dir=Dir.pwd)
    session = Time.now.strftime("%Y%m%d%H%M%S")  # FIXME
    tmpdir  = File.join(Dir.tmpdir, 'quarry', session)

    FileUtils.cp_r(dir, tmpdir)

    return tmpdir
  end

  #
  #
  #
  def conf_dir
    File.expand_path('~/.quarry')
  end

end
