Before :document do
  FileUtils.rm_r('tmp/qed')  if File.exist?('tmp/qed')
end

When 'seed is a directory' do
  @tmpdir = File.join('tmp/qed/bank/demo/')
  withsow = @tmpdir + '.sow'
  FileUtils.mkdir_p(withsow)
end

When 'A simple example of a README might read' do |quote|
  file = @tmpdir + '.sow/README'
  File.open(file, 'w'){ |f| f << quote }
end

When 'An example Sowfile might look something like this' do |quote|
  file = @tmpdir + '.sow/Sowfile'
  File.open(file, 'w'){ |f| f << quote }
end

When "seed directory holds" do
  FileUtils.mkdir_p(@tmpdir)
end

When 'seed directory might', 'have a', 'file called (((\S+)))' do |fname, quote|
  file = @tmpdir + "#{fname}"
  File.open(file, 'w'){ |f| f << quote }
end

