begin
  require "vagrant"
rescue LoadError
  raise "The vagrant-fsnotify plugin must be run within Vagrant."
end

if Vagrant::VERSION < "1.7.3"
  raise <<-ERROR
The vagrant-fsnotify plugin is only compatible with Vagrant 1.7.3+. If you can't
upgrade, consider installing an old version of vagrant-fsnotify with:
  $ vagrant plugin install vagrant-fsnotify --plugin-version 0.0.6.
ERROR
end

module VagrantPlugins::Fsnotify

  class Config < Vagrant.plugin("2", :config)
    attr_accessor :touch

    def initialize
      @touch = UNSET_VALUE
    end

    def finalize!
      @touch = [:modification, :access] if @touch == UNSET_VALUE
    end
  end

end
