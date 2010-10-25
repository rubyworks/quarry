= Seed Layout

A seed is a directory that contains a set of template files along with
a .sow directory which contains a README file and a Sowfile.

The README document simply consists of text describing the seed and
any special arguments if handles that the user will want to know about.
A simple example of a README might read...

  Sample seed will create a sample project layout
  suitable for testing by Sow's test suite.

The Sowfile is a script that collects any information the seed needs
and copies the files from the seed to a staging ground, which is
later copied to the output destination. An example Sowfile might 
look something like this...

  argument :name, :default => 'anonymous'

  copy '**/*'

The seed directory holds all the erb templates and static files that may
be copied. For example, the seed directory might have a template file
called README ...

  Welcome to <%= name %>.

  FIXME: Describe you project here.

  Copyright (c) <%= Time.now.strftime('%Y') %> <%= name %>

The seed directory might also have a static file called LICENSE ...

  Pancake License

  You can do whatever the hell you want with this software
  just so long as lawyers do not become involved.

And that's really all there is to it. That is the basic outline of Sow seed.
The nice thing about Sow seeds is that the layout is straight-forward and the 
Sowfile DSL is very easy to use.

