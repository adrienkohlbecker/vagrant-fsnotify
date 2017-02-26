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

  class Plugin < Vagrant.plugin("2")
    name "vagrant-fsnotify"

    command "fsnotify" do
      require_relative "command-fsnotify"
      Command
    end

    action_hook("up", 'machine_action_up') do |hook|
      require_relative "action/up"
      hook.append(Action::Up)
    end

    action_hook("halt", 'machine_action_halt') do |hook|
      require_relative "action/halt"
      hook.prepend(Action::Halt)
    end

  end

end
