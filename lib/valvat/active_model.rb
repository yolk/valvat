require 'active_model'
require 'valvat/syntax'
require 'valvat/lookup'

module ActiveModel
  module Validations
    class ValvatValidator < ::ActiveModel::EachValidator
      
      def validate_each(record, attribute, value)
        vat = Valvat(value)
        
        is_valid = options[:lookup] ? vat.valid? && vat.exists? : vat.valid?
        is_valid.nil? && is_valid = (options[:lookup] != :fail_if_down)
        
        unless is_valid
          record.errors.add(attribute, :invalid_vat, 
            :message => options[:message], 
            :country_adjective => I18n.t(
              :"valvat.country_adjectives.#{(Valvat::Utils.split(value)[0] || "eu").downcase}", 
              :default => [:"valvat.country_adjectives.eu", "european"]
            )
          )
        end
      end
    end
  end
end

I18n.load_path << File.dirname(__FILE__) + '/../locale/en.yml'