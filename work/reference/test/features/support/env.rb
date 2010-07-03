# Use Assertive Expressive
require 'ae'
require 'ae/expect'
require 'ae/should'

require 'tmpdir'

include FileUtils

$PROJECT_ROOT = (
  dir = File.dirname(__FILE__)
  until Dir[dir + '/README*'].first do
    dir = File.expand_path(File.join(dir, '..'))
  end
  raise "no project root" unless dir
  dir
)

$TEMP_DIR = Dir.tmpdir + '/cucumber/sow'

puts "[tmp] #{$TEMP_DIR}"

Before do
  rm_rf   $TEMP_DIR
  mkdir_p $TEMP_DIR
end

def in_temporary_directory(&block)
  Dir.chdir($TEMP_DIR) do
    block.call
  end
end

def in_project_directory(*name, &block)
  Dir.chdir(File.join($TEMP_DIR, *name)) do
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

