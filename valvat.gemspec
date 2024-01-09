# frozen_string_literal: true

require_relative 'lib/valvat/version'

Gem::Specification.new do |s|
  s.name                    = 'valvat'
  s.version                 = Valvat::VERSION
  s.license                 = 'MIT'
  s.authors                 = ['Sebastian Munz']
  s.email                   = ['sebastian@mite.de']
  s.homepage                = 'https://github.com/yolk/valvat'
  s.summary                 = 'Validates european vat numbers. Standalone or as a ActiveModel validator.'
  s.description             = 'Validates european vat numbers. Standalone or as a ActiveModel validator.'
  s.required_ruby_version   = '>= 2.6.0'
  s.files                   = Dir['lib/**/*.rb']
  s.cert_chain              = ['certs/mite.pem']
  s.signing_key             = File.expand_path('~/.ssh/gem-private_key.pem') if $PROGRAM_NAME.end_with?('gem') && ARGV == ['build', __FILE__]
  s.metadata = {
    'bug_tracker_uri'       => "#{s.homepage}/issues",
    'changelog_uri'         => "#{s.homepage}/blob/master/CHANGES.md",
    'documentation_uri'     => "#{s.homepage}/blob/master/README.md",
    'homepage_uri'          => s.homepage,
    'source_code_uri'       => s.homepage,
    'rubygems_mfa_required' => 'true'
  }

  s.add_runtime_dependency('rexml', '>= 3.2', '< 4.0')
end
