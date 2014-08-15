begin
  require "vagrant"
rescue LoadError
  raise "The vagrant-fsnotify plugin must be run within Vagrant."
end

if Vagrant::VERSION < "1.5"
  raise "The vagrant-fsnotify plugin is only compatible with Vagrant 1.5+"
end

module VagrantPlugins::Fsnotify

  class Plugin < Vagrant.plugin("2")
    name "vagrant-fsnotify"

    command "fsnotify" do
      require_relative "command-fsnotify"
      Command
    end

  end

end
