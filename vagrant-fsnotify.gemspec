# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-fsnotify/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-fsnotify"
  spec.version       = VagrantPlugins::Fsnotify::VERSION
  spec.authors       = ["Adrien Kohlbecker"]
  spec.email         = ["adrien.kohlbecker@gmail.com"]
  spec.summary       = "Forward filesystem change notifications to your Vagrant VM"
  spec.description   = "Use vagrant-fsnotify to forward filesystem change notifications to your Vagrant VM"
  spec.homepage      = "https://github.com/adrienkohlbecker/vagrant-fsnotify"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "listen", "~> 2.7.1"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
