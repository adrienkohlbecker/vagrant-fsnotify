# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.synced_folder ".", "/vagrant", fsnotify: true

  config.vm.provision "shell", inline: "sudo apt-get update && sudo apt-get install -y inotify-tools"
end
