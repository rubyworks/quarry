require 'tmpdir'

$TEMP_DIR = File.join(Dir.tmpdir, "cucumber", File.basename($PROJECT_ROOT))

puts "[$TEMP_DIR] #{$TEMP_DIR}"

Before do
  FileUtils.rm_rf   $TEMP_DIR
  FileUtils.mkdir_p $TEMP_DIR
end

def in_temporary_directory(&block)
  Dir.chdir($TEMP_DIR) do
    block.call
  end
end

