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
     
    entries =[]
    Dir.chdir(@path) do
      entries = Dir.glob("**/*", File::FNM_DOTMATCH)
    end
    entries = entries.reject{ |d| File.basename(d) == '.' or File.basename(d) == '..' }  # this sucks!
    entries = entries.sort

    files = plugin_scaffolding('ruby')
    files = files.map{ |d| d.sub('meta', '.meta') }
    files = files.map{ |d| d.sub('__package__', @name) }
    files = files.sort
    entries.assert == files
  end
end

And /^with the proper project name$/ do
  in_project_directory(@path) do
    File.read('README.rdoc').assert.index(@name)
  end
end

