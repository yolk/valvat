# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "valvat/version"

Gem::Specification.new do |s|
  s.name          = "valvat"
  s.version       = Valvat::VERSION
  s.platform      = Gem::Platform::RUBY
  s.license       = 'MIT'
  s.authors       = ["Sebastian Munz"]
  s.email         = ["sebastian@yo.lk"]
  s.homepage      = "https://github.com/yolk/valvat"
  s.summary       = %q{Validates european vat numbers. Standalone or as a ActiveModel validator.}
  s.description   = %q{Validates european vat numbers. Standalone or as a ActiveModel validator.}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.cert_chain    = ['certs/yolk.pem']
  s.signing_key   = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/
  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency             'savon',       '>= 2.3.0'

  s.add_development_dependency 'rspec',       '~> 3.0'
  s.add_development_dependency 'activemodel', '>= 3.0'
end
