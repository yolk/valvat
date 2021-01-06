# frozen_string_literal: true

require 'active_model'
require 'valvat/syntax'
require 'valvat/lookup'

module ActiveModel
  module Validations
    class ValvatValidator < EachValidator
      def initialize(options)
        normalize_options(options)
        super
      end

      def validate_each(record, attribute, value)
        vat = Valvat(value)
        iso_country_code = vat.iso_country_code

        is_valid = if country_does_not_match?(record, iso_country_code)
                     iso_country_code = iso_country_code_of(record)
                     false
                   else
                     vat_valid?(vat)
                   end

        iso_country_code = 'eu' if iso_country_code.blank?

        add_error(is_valid, record, attribute, iso_country_code)
      end

      private

      def vat_valid?(vat)
        vat.valid? && valid_checksum?(vat) && vat_exists?(vat)
      end

      def valid_checksum?(vat)
        return true unless options[:checksum]

        vat.valid_checksum?
      end

      def vat_exists?(vat)
        return true unless options[:lookup]

        exists = vat.exists?(options[:lookup])

        return true if exists.nil? && !options[:lookup][:fail_if_down]

        exists
      end

      def country_does_not_match?(record, iso_country_code)
        return false unless options[:match_country]

        iso_country_code_of(record) != iso_country_code
      end

      def iso_country_code_of(record)
        (record.send(options[:match_country]) || '').upcase
      end

      def add_error(is_valid, record, attribute, iso_country_code)
        case is_valid
        when false
          add_invalid_vat_error(record, attribute, iso_country_code)
        when nil
          add_vies_down_error(record, attribute)
        end
      end

      def add_invalid_vat_error(record, attribute, iso_country_code)
        record.errors.add(attribute, :invalid_vat,
                          message: options[:message],
                          country_adjective: I18n.t(
                            :"valvat.country_adjectives.#{iso_country_code.downcase}",
                            default: [:"valvat.country_adjectives.eu", 'european']
                          ))
      end

      def add_vies_down_error(record, attribute)
        record.errors.add(attribute, :vies_down,
                          message: options[:vies_down_message])
      end

      def normalize_options(options)
        return unless options[:lookup]

        options[:lookup] = case options[:lookup]
                           when :fail_if_down
                             { fail_if_down: true }
                           when Hash
                             options[:lookup]
                           else
                             {}
                           end
      end
    end
  end
end

I18n.load_path += Dir["#{File.dirname(__FILE__)}/../../valvat/locales/*.yml"]
