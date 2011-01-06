require 'rspec'
require 'active_model'

require File.dirname(__FILE__) + '/../lib/valvat.rb'

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