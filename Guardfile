# frozen_string_literal: true

guard :rspec, cmd: 'bundle exec rspec --color' do
  watch(%r{^spec/(.*)_spec.rb})
  watch(%r{^lib/(.*)\.rb})          { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/spec_helper.rb})   { 'spec' }
end
