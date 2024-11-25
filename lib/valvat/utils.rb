# frozen_string_literal: true

require 'date'

class Valvat
  module Utils
    EU_MEMBER_STATES = %w[AT BE BG CY CZ DE DK EE ES FI FR GR HR HU IE IT LT LU LV MT NL PL PT RO SE SI SK].freeze
    SUPPORTED_STATES = EU_MEMBER_STATES + %w[GB]
    COUNTRY_PATTERN = /\A([A-Z]{2})(.+)\Z/.freeze
    NORMALIZE_PATTERN = /([[:punct:][:cntrl:]]|[[:space:]])+/.freeze
    CONVERT_VAT_TO_ISO_COUNTRY = { 'EL' => 'GR', 'XI' => 'GB' }.freeze
    CONVERT_ISO_TO_VAT_COUNTRY = CONVERT_VAT_TO_ISO_COUNTRY.invert.freeze

    def self.split(vat)
      COUNTRY_PATTERN =~ vat
      result = [Regexp.last_match(1), Regexp.last_match(2)]
      iso_country = vat_country_to_iso_country(result[0])
      country_is_supported?(iso_country) ? result : [nil, nil]
    end

    def self.normalize(vat)
      vat.to_s.upcase.gsub(NORMALIZE_PATTERN, '')
    end

    def self.vat_country_to_iso_country(vat_country)
      CONVERT_VAT_TO_ISO_COUNTRY[vat_country] || vat_country
    end

    def self.iso_country_to_vat_country(iso_country)
      CONVERT_ISO_TO_VAT_COUNTRY[iso_country] || iso_country
    end

    def self.country_is_supported?(iso_country)
      SUPPORTED_STATES.include?(iso_country)
    end

    def self.deep_symbolize_keys(value)
      value = value.transform_keys do |key|
        key.to_sym
      rescue StandardError
        key
      end

      value.transform_values! do |val|
        val.is_a?(Hash) ? deep_symbolize_keys(val) : val
      end
    end

    def self.deep_merge(original_hash, hash_to_merge)
      merger = proc { |_key, v1, v2| v1.is_a?(Hash) && v2.is_a?(Hash) ? v1.merge(v2, &merger) : v2 }
      original_hash.merge(hash_to_merge, &merger)
    end
  end
end
