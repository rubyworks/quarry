covers 'quarry/template/management'

test_case Quarry::Template do

  before do
    # TODO: limit available template to fixtures
  end

  class_method :output do

  end

  class_method :templates do

  end

  class_method :list do
    test 'returns sorted list of template names' do
      Quarry::Template.list
    end
  end

  class_method :find do

  end

  class_method :search do

  end

  class_method :save do

  end

  class_method :update do

  end

  class_method :remove do

  end

  class_method :help do

  end

  class_method :uri_to_name
    test 'for git uri' do
      path = Template.uri_to_name('git://trans.github.com/seeds.git')
      path.assert == "seeds.trans.github.com"
    end

    test 'for svn uri' do
      path = Template.uri_to_name('svn+ssh://mt-example.com@mt-example.com/home/joe/data/svn/repo-name/website1/trunk')
      path.assert == "trunk.website1.repo-name.svn.data.joe.home.mt-example.com"
    end
  end

end
