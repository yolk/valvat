# frozen_string_literal: true

require_relative 'base'
require 'net/http'
require 'json'
require 'time'

class Valvat
  class Lookup
    class BRREG < Base
      # Register with Brønnøysund Register Centre
      # https://data.brreg.no/enhetsregisteret/oppslag/enheter
      ENDPOINT_URL = 'https://data.brreg.no/enhetsregisteret/api/enheter'
      REQUIREMENTS_TO_BE_VALID = {
        'konkurs' => false, # in default?
        'underAvvikling' => false, # under liquidation?
        'registrertIMvaregisteret' => true # vat registered?
      }.freeze
      HEADERS = {
        'Accept' => 'application/vnd.brreg.enhetsregisteret.enhet.v2+json;charset=UTF-8'
      }.freeze

      def perform
        return { valid: false } unless @options[:no]

        parse(fetch(endpoint_uri).body)
      end

      private

      def endpoint_uri
        endpoint = "/#{extract_org_number(@vat)}"
        URI.parse(ENDPOINT_URL + endpoint)
      end

      def extract_org_number(vat)
        vat.to_s_wo_country[0..8]
      end

      def build_request(uri)
        Net::HTTP::Get.new(uri.request_uri, HEADERS)
      end

      def parse(body)
        return { valid: false } if body.empty?

        convert(JSON.parse(body))
      end

      # Return a similar format to VIES
      def convert(raw)
        return { valid: false } unless raw >= REQUIREMENTS_TO_BE_VALID
        return build_fault(raw) if raw.key?('code')

        {
          address: format_address(raw['forretningsadresse']),
          country_code: raw.dig('forretningsadresse', 'landkode'),
          name: raw['navn'],
          vat_number: "#{raw['organisasjonsnummer']}MVA",
          valid: true
        }
      end

      # Example raw address from the API:
      # "forretningsadresse": {
      #   "land": "Norge",
      #   "landkode": "NO",
      #   "postnummer": "0160",
      #   "poststed": "OSLO",
      #   "adresse": [
      #     "Fridtjof Nansens plass 7"
      #   ],
      #   "kommune": "OSLO",
      #   "kommunenummer": "0301"
      # },
      def format_address(raw_address)
        lines = {}
        address_strings = raw_address['adresse']
        address_strings.each_with_index do |item, index|
          lines[:"line#{index + 1}"] = item
        end

        address_details = {
          postcode: raw_address['postnummer'],
          city: raw_address['poststed']
        }

        address = lines.merge(address_details).compact

        address.values.join(', ')
      end

      def build_fault(raw)
        fault = raw['code']
        return { valid: false } if fault == 'NOT_FOUND'

        exception = FAULTS[fault] || UnknownLookupError
        { error: exception.new("#{fault}#{raw['message'] ? " (#{raw['message']})" : ''}", self.class) }
      end
    end
  end
end
