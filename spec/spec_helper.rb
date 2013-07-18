require 'rspec'
begin
  require 'active_model'
rescue LoadError => err
  puts "Running specs without active_model extension"
end
require 'fakeweb'

require File.dirname(__FILE__) + '/../lib/valvat.rb'

$fakeweb = true

RSpec.configure do |config|
  config.mock_with :rspec
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.backtrace_exclusion_patterns = [/rspec\/(core|expectations)/]
end

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

def without_any_web_requests!
  before(:all) do
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = false
  end
  after(:all) do
    FakeWeb.allow_net_connect = true
  end
end
