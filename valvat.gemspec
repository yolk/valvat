# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'valvat/version'

Gem::Specification.new do |s|
  s.name                              = 'valvat'
  s.version                           = Valvat::VERSION
  s.platform                          = Gem::Platform::RUBY
  s.license                           = 'MIT'
  s.authors                           = ['Sebastian Munz']
  s.email                             = ['sebastian@mite.de']
  s.homepage                          = 'https://github.com/yolk/valvat'
  s.summary                           = 'Validates european vat numbers. Standalone or as a ActiveModel validator.'
  s.description                       = 'Validates european vat numbers. Standalone or as a ActiveModel validator.'
  s.files                             = Dir['lib/**/*.rb']
  s.require_paths                     = ['lib']
  s.cert_chain                        = ['certs/mite.pem']
  s.signing_key                       = File.expand_path('~/.ssh/gem-private_key.pem') if $PROGRAM_NAME =~ /gem\z/
  s.metadata['rubygems_mfa_required'] = 'true'
  s.required_ruby_version             = '>= 2.6.0'

  s.add_runtime_dependency('rexml', '>= 3.2', '< 4.0')
end
