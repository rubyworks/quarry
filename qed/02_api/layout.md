# Layout

The layout of an "ore" directory, whcih contains a set of template files
along with an .ore directory which contains a README file and a copy.rb file.

The README document simply consists of text describing the seed and
any special arguments if handles that the user will want to know about.
It is expetect to be markdown, and optionally ronn-style markdown.

A simple example of a README might read:

    quarry-myore - simple ore example
    =================================

    ## SYNOPSIS

    Sample ore will create a sample project layout
    suitable for testing by Quarry's test suite.

The `copy.rb` file is a script that collects any information the ore needs
and copies the files from the ore to a staging ground, which is later copied
to the output destination. An example copy.rb file might look something like:

    argument :name, :default => 'anonymous'

    copy '**/*'

The ore directory holds all the ERB templates and static files that may
be copied. For example, the seed directory might have a template file
called README:

    # <%= name %> - <%= summary %>
    
    <%= description %>

    Copyright (c) <%= Time.now.strftime('%Y') %> <%= name %>

The ore directory might also have a static file called LICENSE:

    Pancake License

    You can do whatever the hell you want with this software
    just so long as lawyers do not become involved.

And that's really all there is to it. That is the basic outline of Quarry ore.
The nice thing about ore is that the layout is straight-forward and the 
copy.rb DSL is very easy to use.

