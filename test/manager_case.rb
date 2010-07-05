Covers 'sow/manager'

TestCase Sow::Manager do

  MetaUnit :bank_folder => '' do
    raise Pending
  end

  MetaUnit :read_setting => '' do
    raise Pending
  end

  MetaUnit :silo_folder => '' do
    raise Pending
  end

  Unit :bank_folder => '' do
    raise Pending
  end

  Unit :options => '' do
    raise Pending
  end

  Unit :list => '' do
    raise Pending
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

  Unit :shell => '' do
    raise Pending
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

  Unit :silo_folder => '' do
    raise Pending
  end

  Unit :seeds => '' do
    raise Pending
  end

  Unit :find_seed => '' do
    raise Pending
  end

  Unit :trial? => '' do
    raise Pending
  end

  Unit :map => '' do
    raise Pending
  end

  Unit :find_bank => '' do
    raise Pending
  end

  Unit :readme => '' do
    raise Pending
  end

  Unit :silos => '' do
    raise Pending
  end

end
