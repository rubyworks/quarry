= Sow -- Quick Start Guide

  Tending Project Ecology

  http://sow.rubyforge.org


== Introduction

Sow is a project scaffolding generator. Techincally it is a simple templating system
based on eRuby, but it is designed with project templating squarely in mind.


== Installation

Install using RubyGems as you would expect:

  $ gem install sow

There is no manual install at the moment. This will be fixed in a future release.


== Usage

To scaffold a new project try:

  $ sow myapp

You will see the following output:

  Transferring reap -> myapp:

      create  CHANGES
      create  COPYING
      create  METADATA
      create  NEWS
      create  README
      create  admin
      create  admin/config
      create  admin/pkg
      create  admin/temps
      create  admin/temps/lib
      create  admin/temps/lib/myapp
      create  admin/temps/lib/myapp/about.rb.erb
      create  admin/web
      create  bin
      create  data
      create  doc
      create  doc/rdoc
      create  doc/ri
      create  lib
      create  lib/my-app
      create  test

  You need to fix the occurances of 'FIX' in the following files:

      README

Note the mention of 'reap'. By default Sow scaffolds a project suitable
for use with the Reap build system.  This is a good project layout even
if you aren't using Reap. But reap support other scaffold types as well.
Simply sepcify the type before the project/directory name. For instance,
if you prefere an old-fashioned Ruby project:

  $ sow ruby myapp

With your project in place, be sure to go over the contents and fine-tune them.
In particular, edit the files that contain 'FIX' entries.

Sow operates in generation mode when you are in a "sow-ready" project.
Sow idetifies such a project by a @.sow@ directory located in the projects
root folder.

We can use partial scaffolds too. For instance you may want to add a standard
Rakefile. You can do that with Sow:

  $ cd myapp
  $ sow ruby Rakefile

Sow can continue to be used for in-project templates. To do this, add templates
to the temps/ or admin/temps directories, reflecting the same layout of your project.
For example:

  myapp/
    lib/
      myapp/
        myapp.rb
    temps/
      lib/
        myapp/
          myapp.rb.erb
    meta/
      ...

Change into your project directory and run:

  $ sow

Project files will be generated based on the templates and metadata entries.


== Hoe Users

Hoe users will notice that the sow command that comes with Hoe is overwritten by Sow. Sow support Hoe
projects, so there is nothing lost. Simply use:

  $ sow hoe

Note, that Hoe scaffolding does not support the in-project templating system. To get that you need to create a meta/
direcroty in your project, and a place to store templates, eg. temps/.


== Copying

Copyright (c) 2007, 2008 TigerOps

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.

