#!/usr/bin/env ruby
#
#  Created <%= "by #{author} " if author %>on <%= (now = Time.now).year %>-<%= now.month %>-<%= now.day %>.
#  Copyright (c) <%= now.year %>. All rights reserved.
#
# TODO: write executable
#
# It might be something like the following.

require '<%= package %>/command.rb'
<%= title %>::Command.execute

