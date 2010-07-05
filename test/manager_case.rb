Covers 'sow/manager'

TestCase Sow::Manager do

  Before do
    @manager = Sow::Manager.new
  end

  MetaUnit :bank_folder => '' do
    path = Pathname.new(File.expand_path(Sow::Manager::SOW_CONFIG + '/bank'))
    Sow::Manager.bank_folder.assert == path
  end

  MetaUnit :silo_folder => '' do
    path = Pathname.new(File.expand_path(Sow::Manager::SOW_CONFIG + '/silo'))
    Sow::Manager.silo_folder.assert == path
  end

  MetaUnit :read_setting => '' do
    raise Pending
  end

  Unit :bank_folder => '' do
    path = Pathname.new(File.expand_path(Sow::Manager::SOW_CONFIG + '/bank'))
    @manager.bank_folder.assert == path
  end

  Unit :silo_folder => '' do
    path = Pathname.new(File.expand_path(Sow::Manager::SOW_CONFIG + '/silo'))
    @manager.silo_folder.assert == path
  end

  Unit :options => '' do
    manager = Sow::Manager.new(:skip=>true)
    manager.options.assert.is_a?(OpenStruct)
    manager.options.skip.assert == true
  end

  Unit :seed_map => '' do
    seed_map = @manager.seed_map
    # how best to test further ?
  end

  Unit :seeds => 'returns a list available of seed names' do
    @manager.seeds.assert.include?('ruby')
  end

  Unit :list => 'is an alias for seeds' do
    @manager.list.assert == @manager.seeds
  end

  Unit :update => '' do
    raise Pending
  end

  Unit :banks => '' do
    raise Pending
  end

  Unit :uri_to_name => 'for git uri' do
    manager = Sow::Manager.new
    path = manager.uri_to_name('git://trans.github.com/seeds.git')
    path.assert == "seeds.trans.github.com"
  end

  Unit :uri_to_name => 'for svn uri' do
    manager = Sow::Manager.new
    path = manager.uri_to_name('svn+ssh://mt-example.com@mt-example.com/home/joe/data/svn/repo-name/website1/trunk')
    path.assert == "trunk.website1.repo-name.svn.data.joe.home.mt-example.com"
  end

  Unit :path_to_name => '' do
    raise Pending
  end

  Unit :uninstall => '' do
    raise Pending
  end

  Unit :save => '' do
    raise Pending
  end

  Unit :install => '' do
    raise Pending
  end

  Unit :remove => '' do
    raise Pending
  end

  Unit :find_seed => '' do
    @manager.find_seed('ruby')
  end

  Unit :trial? => 'is the same as $DRYRUN' do
    @manager.trial?.assert == $DRYRUN
  end

  Unit :find_bank => '' do
    raise Pending
    #@manager.find_bank('')
  end

  Unit :readme => '' do
    @manager.readme('ruby')
  end

  Unit :silos => '' do
    @manager.silos
  end

end
