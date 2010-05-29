
__DIR__ = File.dirname(__FILE__)

require __DIR__ + '/ae'
require __DIR__ + '/tmp'
require __DIR__ + '/fs'

$PROJECT_ROOT = (
  dir = File.dirname(__FILE__)
  until Dir[dir + '/README*'].first do
    dir = File.expand_path(File.join(dir, '..'))
  end
  raise "no project root" unless dir
  dir
)

def in_project_directory(*name, &block)
  Dir.chdir(File.join($TEMP_DIR, *name)) do
    block.call
  end
end

