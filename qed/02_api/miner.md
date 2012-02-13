# Generator

The Generator class is the primary controller of the Sow system. By setting
up a Generator object, it can be used to "germinate" new seeds.

    require 'quarry/generator'

Given that we have a seed as defined in layout.rdoc[qed://layout.rdoc].
To create a generator we need a seed, the +destination+ for the new scaffolding,
and any general options that control operation, such as +write+, +skip+, etc.

    dir  = 'tmp/qed/myapp'

    opts = {:skip=>true, :output=>dir}

    ore  = Sow::Scaffold.new('demo', ['myapp'], {'name'=>'Sow Demo'}, opts)

    gen  = Sow::Generator.new([seed], opts)

With the instantiation of a Generator, a fair amount of information is
setup.

    gen.output.assert == 'tmp/qed/myapp'

We will not go into the Seed class here (see seed.rdoc for that), but to point
out that it extecutes the seed's Sowfile which updates a stagged copy of
the destination. It is this staged set of files that is ultimately copied back
to the output directory.

    silently do
      gen.generate
    end

Now if we look in the designated output directory, we will find our demo files.

    File.assert.exist?(dir + '/README')
    File.assert.exist?(dir + '/LICENSE')

And we will likewise see that README has been filled in with the settings
metadata.

    File.read(dir + '/README').include?('Sow Demo')

