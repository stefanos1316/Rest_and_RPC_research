# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sr/jimson'

Gem::Specification.new do |spec|
  spec.name          = "sr-jimson"
  spec.version       = Sr::Jimson::VERSION
  spec.authors       = ["Chris Kite", "Jorge Calás Lozano"]
  spec.email         = ["chris@chriskite.com", "calas@qvitta.net"]
  spec.description   = %q{Speedyrails fork of jimson JSON-RPC 2.0 client and server}
  spec.summary       = %q{JSON-RPC 2.0 client and server}
  spec.homepage      = "http://www.github.com/speedyrails/sr-jimson"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client", "~> 1.0"
  spec.add_dependency "multi_json", "~> 1.0"
  spec.add_dependency "rack", "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency "rdoc", ">= 2.4.2"
end
