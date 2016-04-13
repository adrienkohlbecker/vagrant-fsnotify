require 'daemons'

module VagrantPlugins::Fsnotify::Action
  class Halt
    def initialize(app, env)
      @app = app
    end

    def call(env)
      @app.call(env)
      halt env
    end

    protected
      def halt(env)
        task = VagrantPlugins::Fsnotify.task
        task.stop
      end
  end
end
