Before :document do
  FileUtils.rm_r('tmp/bank')  if File.exist?('tmp/bank')
  FileUtils.rm_r('tmp/myapp') if File.exist?('tmp/myapp')
end

When 'seed is a directory' do
  @tmpdir = File.join('tmp/bank/demo/')
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
  FileUtils.mkdir_p(@tmpdir + 'template')
end

When 'seed directory might', 'have a', 'file called (((\S+)))' do |fname, quote|
  file = @tmpdir + "#{fname}"
  File.open(file, 'w'){ |f| f << quote }
end

