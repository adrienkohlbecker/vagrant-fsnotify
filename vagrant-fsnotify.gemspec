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

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
