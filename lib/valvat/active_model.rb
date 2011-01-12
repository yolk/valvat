require 'active_model'
require 'valvat/syntax'
require 'valvat/lookup'

module ActiveModel
  module Validations
    class ValvatValidator < ::ActiveModel::EachValidator
      
      def validate_each(record, attribute, value)
        vat = Valvat(value)
        is_valid = options[:lookup] ? vat.valid? && vat.exists? : vat.valid?
        
        if is_valid.nil?
          is_valid = options[:lookup] != :fail_if_down
        end
        
        if is_valid && options[:match_country]
          is_valid = (record.send(options[:match_country]) || "").upcase == vat.iso_country_code
        end
        
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

%w(en de).each do |locale|
  I18n.load_path << "#{File.dirname(__FILE__)}/../locale/#{locale}.yml"
end