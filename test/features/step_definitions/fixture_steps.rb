Given /^I want to create a new "(.*)" project$/ do |type|
  @type = type
end

And /^I want the project to be called "(.*)"$/ do |name|
  @name = name
end

And /^I want to place it in a directory with the same name$/ do
  @path = @name
end

And /^I want to place it in a directory "(.*)"$/ do |path|
  @path = path
end

Given /^there is no project directory/ do
  in_temporary_directory do
    rm_r(@path) if File.exist?(@path)
  end
end

Given /^a command option "(.*)"$/ do |opt|
  @option = opt
  if /=/ =~ @option
    @name = @option.split('=').last
  end
end

And /^a command argument$/ do |arg|
  @argument = arg
  if /=/ !~ @option
    @name = arg
  end
end

When /^I execute sow$/ do
  if @path = @name
    cmd = %|sow --#{@type} #{@path}|
  else
    cmd = %|sow --#{@type}=#{@name} #{@path}|
  end
  in_temporary_directory do
    system cmd
  end
end

Then /^a standard ruby project will be generated$/ do
  in_temporary_directory do
    File.assert.exist?(@path)
    entries = Dir.entries(@path).sort - ['.', '..']
    entries.assert == %w{.autotest History.txt Manifest.txt README.txt Rakefile bin lib test}
  end
end

And /^with the proper project name$/ do
  in_project_directory(@path) do
    File.read('README.txt').assert.index(@name)
  end
end
