# frozen_string_literal: true

require 'date'

class Valvat
  module Utils
    EU_MEMBER_STATES = %w[AT BE BG CY CZ DE DK EE ES FI FR GR HR HU IE IT LT LU LV MT NL PL PT RO SE SI SK].freeze
    SUPPORTED_STATES = EU_MEMBER_STATES + %w[GB]
    EU_COUNTRIES = EU_MEMBER_STATES # TODO: Remove constant
    COUNTRY_PATTERN = /\A([A-Z]{2})(.+)\Z/.freeze
    NORMALIZE_PATTERN = /[[:space:][:punct:][:cntrl:]]+/.freeze
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
  end
end
