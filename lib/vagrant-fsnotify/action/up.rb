require 'daemons'
require 'vagrant-fsnotify/daemon'

module VagrantPlugins::Fsnotify::Action
  class Up
    def initialize(app, env)
      @app = app
    end

    def call(env)
      VagrantPlugins::Fsnotify::Daemon.new(env).start
      env[:ui].info "Started fsnotify daemon."
      @app.call(env)
    end
  end
end
