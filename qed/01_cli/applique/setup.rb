$LOAD_PATH.unshift('lib')

require 'sow'
require 'shellwords'
require "stringio"

SAMPLES = File.dirname(File.dirname(__FILE__)) + '/samples'
TEMPDIR = 'tmp/qed/system'

SOW_HOME = TEMPDIR + '/sow_home'

# redirect sow home to tmp location
Sow::Manager::SOW_CONFIG.replace(SOW_HOME)

def `(command)    # comment here b/c of dumb syntax highligters`
  command.sub!(/^sow/,'')
  argv = Shellwords.shellwords(command)
  $stdout, $stderr = StringIO.new, StringIO.new
  Sow.cli(*argv)
  $stdout.rewind; $stderr.rewind
  @out, @err = $stdout.read, $stderr.read
  $stdout, $stderr = STDOUT, STDERR
  @out
end

Before :document do
  FileUtils.rm_rf('tmp/qed') if File.exist?('tmp/qed')
  FileUtils.mkdir_p(File.dirname(TEMPDIR))
  FileUtils.cp_r(SAMPLES, TEMPDIR)
end

When "given an empty temporary directory '(((.*?)))'" do |name|
  FileUtils.rm_r("tmp/qed/#{name}") if File.exist?("tmp/qed/#{name}")
  FileUtils.mkdir_p("tmp/qed/#{name}")
end

When "'(((.*?)))' project already has a README file" do |name|
  FileUtils.rm_r("tmp/qed/#{name}") if File.exist?("tmp/#{name}")
  #FileUtils.mkdir_p('tmp/foo/.sow')
  FileUtils.mkdir_p("tmp/qed/#{name}")
  File.open("tmp/qed/#{name}/README", 'w'){ |f| f << "ipso\n" * 10 }
end

#When "we have a seed bank at '(((.*?)))'" do |path|
#  FileUtils.mkdir_p(File.join(SOW_HOME, path))
#end

When "output will look like this" do |text|
  @out.tabto(0).strip.assert == text.tabto(0).strip
end

# Some helper methods

def seed_bank_exists?(name)
  File.directory?(File.join(SOW_HOME, 'bank', name))
end

def seed_silo_exists?(name)
  File.directory?(File.join(SOW_HOME, 'silo', name))
end

