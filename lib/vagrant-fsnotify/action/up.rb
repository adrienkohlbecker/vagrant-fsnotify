require 'daemons'

module VagrantPlugins::Fsnotify::Action
  class Up
    def initialize(app, env)
      @app = app
    end

    def call(env)
      up
      @app.call(env)
    end

    protected
      def up
        task = Daemons.call do
          VagrantPlugins::Fsnotify::Command.execute
        end
        task.start
        VagrantPlugins::Fsnotify.task = task
      end
  end
end