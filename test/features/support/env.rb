# Use Assertive Expressive
require 'ae'
require 'ae/expect'
require 'ae/should'

require 'tmpdir'

include FileUtils

$PROJECT_ROOT = File.expand_path(File.dirname(__FILE__) + '../../../..')
$TMP_DIR = Dir.tmpdir + '/cucumber/sow'

puts "[tmpdir] #{$TMP_DIR}"

Before do
  @tmp_path = $TMP_DIR
  #@tmp_path = File.expand_path(File.dirname(__FILE__) + '../../../../.cache/cucumber')
  rm_rf   @tmp_path
  mkdir_p @tmp_path
end

def in_temporary_directory(&block)
  Dir.chdir(@tmp_path) do
    block.call
  end
end

def in_project_directory(*name, &block)
  Dir.chdir(File.join(@tmp_path, *name)) do
    block.call
  end
end

def plugin_scaffolding(name)
  files = []
  Dir.chdir($PROJECT_ROOT + "/plug/sow/seeds/#{name}/template/") do
    files = Dir["**/*"]
  end
  files.sort
end

