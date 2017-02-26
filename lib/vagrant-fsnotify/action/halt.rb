require 'daemons'
require 'vagrant-fsnotify/daemon'

module VagrantPlugins::Fsnotify::Action
  class Halt
    def initialize(app, env)
      @app = app
    end

    def call(env)
      VagrantPlugins::Fsnotify::Daemon.new(env).stop
      env[:ui].info "Stopped fsnotify daemon."
      @app.call(env)
    end
  end
end
