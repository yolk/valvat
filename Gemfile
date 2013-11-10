source 'http://rubygems.org'

# Specify your gem's dependencies in valvat.gemspec
gemspec

gem 'rake'
gem 'guard-rspec', '~>4.0'
gem 'rb-fsevent' if RUBY_PLATFORM.include?("x86_64-darwin")

platform :rbx do
  gem 'racc'
  gem 'rubysl'
end