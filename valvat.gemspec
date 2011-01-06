# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "valvat/version"

Gem::Specification.new do |s|
  s.name        = "valvat"
  s.version     = Valvat::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sebastian Munz"]
  s.email       = ["sebastian@yo.lk"]
  s.homepage    = "https://github.com/yolk/valvat"
  s.summary     = %q{Validates european vat numbers. Supports simple syntax verification and lookup via the VIES web service.}
  s.description = %q{Validates european vat numbers. Supports simple syntax verification and lookup via the VIES web service.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency 'rspec', '>= 2.4.0'
  s.add_development_dependency 'guard-rspec', '>=0.1.9'
  s.add_development_dependency 'growl', '>=1.0.3'
  s.add_development_dependency 'rb-fsevent', '>=0.3.9'
end
