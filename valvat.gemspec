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
  s.summary     = %q{Validates european vat numbers. Standalone or as a ActiveModel validator.}
  s.description = <<-END
  Validates european vat numbers. Standalone or as a ActiveModel validator.

  * Simple syntax verification
  * Lookup via the VIES web service
  * Works standalone without any gem dependencies
  * (Optional) ActiveModel/Rails3 integration
  * I18n locales for country specific error messages
  END



  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency             'savon',       '>=0.8.2'

  s.add_development_dependency 'rspec',       '>= 2.4.0'
  s.add_development_dependency 'guard-rspec', '>=0.1.9'
  s.add_development_dependency 'growl',       '>=1.0.3'
  s.add_development_dependency 'rb-fsevent',  '>=0.3.9'
  s.add_development_dependency 'activemodel', '>=3.0'
  s.add_development_dependency 'fakeweb',     '>= 1.3.0'
end
