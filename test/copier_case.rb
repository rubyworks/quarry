Covers 'sow/copier'

TestCase Sow::Copier do

  source = 'test/samples/source'
  output = 'test/samples/output'

  Unit :source => '' do
    copier = Sow::Copier.new(source, output)
    copier.source.assert = Pathname.new(File.expand_path(source))
  end

  Unit :output => '' do
    copier = Sow::Copier.new(source, output)
    copier.output.assert = Pathname.new(File.expand_path(output))
  end

  Unit :options => '' do
    copier = Sow::Copier.new(source, output, :mode=>:skip)
    copier.options.assert.is_a?(Hash)
    copier.options[:mode] == :skip
  end

  Unit :skip? => 'is true if mode is skip' do
    copier = Sow::Copier.new(source, output, :mode=>:skip)
    copier.assert.skip?
    copier = Sow::Copier.new(source, output, :mode=>:write)
    copier.refute.skip?
    copier = Sow::Copier.new(source, output)
    copier.refute.skip?
  end

  Unit :write? => 'is ture if mode is write' do
    copier = Sow::Copier.new(source, output, :mode=>:write)
    copier.assert.write?
    copier = Sow::Copier.new(source, output, :mode=>:skip)
    copier.refute.write?
    copier = Sow::Copier.new(source, output)
    copier.refute.write?
  end

  Unit :prompt? => 'is true if mode is prompt' do
    copier = Sow::Copier.new(source, output, :mode=>:prompt)
    copier.assert.prompt?
    copier = Sow::Copier.new(source, output)
    copier.refute.prompt?
  end

  Unit :managed? => 'false if mode is nil' do
    copier = Sow::Copier.new(source, output)
    copier.refute.managed?
  end

  Unit :managed? => 'true if mode is write' do
    copier = Sow::Copier.new(source, output, :mode=>:write)
    copier.assert.managed?
  end

  Unit :managed? => 'true if mode is skip' do
    copier = Sow::Copier.new(source, output, :mode=>:skip)
    copier.assert.managed?
  end

  Unit :managed? => 'true if mode is prompt' do
    copier = Sow::Copier.new(source, output, :mode=>:prompt)
    copier.assert.managed?
  end

  Unit :debug? => 'is the same as $DEBUG' do
    copier = Sow::Copier.new(source, output)
    copier.debug?.assert == $DEBUG
  end

  Unit :trial? => 'is the same as $DRYRUN' do
    copier = Sow::Copier.new(source, output)
    copier.trial?.assert == $DRYRUN
  end

  Unit :backup? => 'true unless specifically set to false' do
    copier = Sow::Copier.new(source, output)
    copier.assert.backup?
    copier = Sow::Copier.new(source, output, :backup=>false)
    copier.refute.backup?
  end

  Unit :logger => '' do
    copier = Sow::Copier.new(source, output, :quiet=>true)
    copier.logger.assert.is_a?(Sow::Logger)
  end

  Unit :quiet? => '' do
    copier = Sow::Copier.new(source, output, :quiet=>true)
    copier.assert.quiet?
    copier = Sow::Copier.new(source, output, :quiet=>false)
    copier.refute.quiet?
  end

  Unit :copylist => '' do
    copier = Sow::Copier.new(source, output, :quiet=>true)
    copier.copylist.assert = ['README']
  end

  Unit :copy => '' do
    raise Pending
  end

  Unit :identical? => '' do
    raise Pending
  end

end

