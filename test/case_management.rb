covers 'quarry/template/management'

test_case Quarry::Template do

  class_method :output do
    Quarry::Template.output.assert == Pathname.new(Dir.pwd)
  end

  class_method :templates do
    test 'returns list of templates' do
      Quarry::Template.templates.size.assert = 1
      Quarry::Template.templates.first.class.assert == Quarry::Template
    end
  end

  class_method :list do
    test 'returns sorted list of template names' do
      Quarry::Template.list.assert = ['example']
    end
  end

  class_method :find do
    test "can find template with full name" do
      Quarry::Template.find('example')
    end

    test "can find template with unique first portion of name" do
      Quarry::Template.find('ex')
    end
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

  class_method :uri_to_name do
    test 'for git uri' do
      path = Quarry::Template.uri_to_name('git://trans.github.com/seeds.git')
      path.assert == "seeds.trans.github.com"
    end

    test 'for svn uri' do
      path = Quarry::Template.uri_to_name('svn+ssh://mt-example.com@mt-example.com/home/joe/data/svn/repo-name/website1/trunk')
      path.assert == "website1.repo-name.svn.data.joe.home.mt-example.com"
    end
  end

end
