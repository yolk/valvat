require 'active_model'
require 'valvat/syntax'
require 'valvat/lookup'

module ActiveModel
  module Validations
    class ValvatValidator < ::ActiveModel::EachValidator

      def validate_each(record, attribute, value)
        vat = Valvat(value)
        iso_country_code = vat.iso_country_code
        is_valid = true

        if options[:match_country]
          iso_country_code = (record.send(options[:match_country]) || "").upcase
          is_valid = iso_country_code == vat.iso_country_code
        end

        if is_valid
          is_valid = options[:lookup] ? vat.valid? && vat.exists? : vat.valid?

          if is_valid.nil?
            is_valid = options[:lookup] != :fail_if_down
          end
        end

        unless is_valid
          iso_country_code = "eu" if iso_country_code.blank?
          record.errors.add(attribute, :invalid_vat,
            :message => options[:message],
            :country_adjective => I18n.t(
              :"valvat.country_adjectives.#{iso_country_code.downcase}",
              :default => [:"valvat.country_adjectives.eu", "european"]
            )
          )
        end
      end
    end
  end
end

I18n.load_path += Dir["#{File.dirname(__FILE__)}/locales/*.yml"]
