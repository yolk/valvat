# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'valvat/version'

Gem::Specification.new do |s|
  s.name          = 'valvat'
  s.version       = Valvat::VERSION
  s.platform      = Gem::Platform::RUBY
  s.license       = 'MIT'
  s.authors       = ['Sebastian Munz']
  s.email         = ['sebastian@yo.lk']
  s.homepage      = 'https://github.com/yolk/valvat'
  s.summary       = 'Validates european vat numbers. Standalone or as a ActiveModel validator.'
  s.description   = 'Validates european vat numbers. Standalone or as a ActiveModel validator.'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']
  s.cert_chain    = ['certs/yolk.pem']
  s.signing_key   = File.expand_path('~/.ssh/gem-private_key.pem') if $PROGRAM_NAME =~ /gem\z/
  s.required_ruby_version = '>= 2.5.0'

  s.add_dependency             'savon', '>= 2.3.0'

  s.add_development_dependency 'activemodel', '>= 5.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.0'
end
