require 'active_model'
require 'valvat/syntax'
require 'valvat/lookup'

module ActiveModel
  module Validations
    class ValvatValidator < EachValidator
      def initialize(options)
        if options[:lookup]
          options[:lookup] = if options[:lookup] == :fail_if_down
            {fail_if_down: true}
          elsif options[:lookup].is_a?(Hash)
            options[:lookup]
          else
            {}
          end
        end

        super
      end

      def validate_each(record, attribute, value)
        vat = Valvat(value)
        iso_country_code = vat.iso_country_code

        if country_does_not_match?(record, iso_country_code)
          iso_country_code = iso_country_code_of(record)
        elsif vat.valid? && valid_checksum?(vat) && vat_exists?(vat)
          return
        end

        iso_country_code = "eu" if iso_country_code.blank?
        record.errors.add(attribute, :invalid_vat,
          message: options[:message],
          country_adjective: I18n.t(
            :"valvat.country_adjectives.#{iso_country_code.downcase}",
            default: [:"valvat.country_adjectives.eu", "european"]
          )
        )
      end

      private

      def country_does_not_match?(record, iso_country_code)
        return false unless options[:match_country]
        iso_country_code_of(record) != iso_country_code
      end

      def iso_country_code_of(record)
        (record.send(options[:match_country]) || "").upcase
      end

      def valid_checksum?(vat)
        return true unless options[:checksum]
        vat.valid_checksum?
      end

      def vat_exists?(vat)
        return true unless options[:lookup]

        is_valid = vat.exists?(options[:lookup])
        return is_valid unless is_valid.nil?
        !options[:lookup][:fail_if_down]
      end
    end
  end
end

I18n.load_path += Dir["#{File.dirname(__FILE__)}/../../valvat/locales/*.yml"]
