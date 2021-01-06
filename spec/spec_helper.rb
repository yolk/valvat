# frozen_string_literal: true

require 'rspec'
begin
  require 'active_model'
rescue LoadError
  puts 'Running specs without active_model extension'
end

require "#{File.dirname(__FILE__)}/../lib/valvat.rb"

RSpec.configure do |config|
  config.mock_with :rspec
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.backtrace_exclusion_patterns = [%r{rspec/(core|expectations)}]
end

I18n.enforce_available_locales = false if defined?(I18n)

if defined?(ActiveModel)
  class ModelBase
    include ActiveModel::Serialization
    include ActiveModel::Validations

    attr_accessor :attributes

    def initialize(attributes = {})
      @attributes = attributes
    end

    def read_attribute_for_validation(key)
      @attributes[key]
    end
  end
end
