require 'daemons'

module VagrantPlugins::Fsnotify
  class Daemon
    attr_accessor :machine
    attr_accessor :tmp_path

    def initialize(env)
      self.machine = env[:machine]
      self.tmp_path = File.join(self.machine.env.tmp_path, "fsnotify")
      FileUtils.mkdir_p(self.tmp_path)
    end

    def start
      run_options = {:ARGV => ["start"]}.merge(runopts)
      run(run_options)
    end

    def stop
      run_options = {:ARGV => ["stop"]}.merge(runopts)
      run(run_options)
    end

    protected

    def run(run_options)
      Daemons.run_proc("vagrant-fsnotify", run_options) do
        self.machine.env.cli("fsnotify")
      end
    end

    def runopts
      {
        :dir_mode   => :normal,
        :dir        => tmp_path,
        :log_output => true,
        :log_dir    => tmp_path
      }
    end
  end
end
