When 'seed is a directory' do
  @tmpdir = File.join(Dir.tmpdir, 'sow/sources/test/demo/')
  FileUtils.mkdir_p(@tmpdir)
end

When 'A simple example of a README might read' do |quote|
  file = @tmpdir + 'README'
  File.open(file, 'w'){ |f| f << quote }
end

When 'An example Sowfile might look something like this' do |quote|
  file = @tmpdir + 'Sowfile'
  File.open(file, 'w'){ |f| f << quote }
end

When "template directory holds" do
  FileUtils.mkdir_p(@tmpdir + 'template')
end

When 'template directory might', 'have a', 'file called (((\S+)))' do |fname, quote|
  file = @tmpdir + "template/#{fname}"
  File.open(file, 'w'){ |f| f << quote }
end

