=begin
require 'clio/commandline'

module Sow

  ### = Runmode
  ###
  ### Subclass of Clio::Runmode, provides common
  ### global command line options: dryrun, force,
  ### verbose, quiet, etc.
  class Commandline < ::Clio::Commandline
    attr :create?
    attr :update?, :u?
    attr :destroy?

    attr :help?
    attr :trace?
    attr :debug?
    attr :dryrun?, :noharm?, :n? #pretend?

    attr :quiet?, :q?
    attr :verbose?

    attr :ask?
    attr :skip?
    attr :force?

    # Generate to a specific subdirectoy.
    attr :output, :o
  end

end
=end

