# frozen_string_literal: true

require_relative 'base'
require 'net/http'
require 'json'

class Valvat
  class Lookup
    class HMRC < Base
      ENDPOINT_URL = 'https://api.service.hmrc.gov.uk/organisations/vat/check-vat-number/lookup'
      HEADERS = {
        # https://developer.service.hmrc.gov.uk/api-documentation/docs/reference-guide#versioning
        'Accept' => 'application/vnd.hmrc.1.0+json'
      }.freeze

      def perform
        parse(fetch(endpoint_uri).body)
      end

      private

      def endpoint_uri
        endpoint = "/#{@vat.to_s_wo_country}"
        endpoint += "/#{@requester.to_s_wo_country}" if @requester
        URI.parse(ENDPOINT_URL + endpoint)
      end

      def build_request(uri)
        Net::HTTP::Get.new(uri.request_uri, HEADERS)
      end

      def parse(body)
        convert(JSON.parse(body))
      end

      # Return a similar format to VIES
      # Main differences are:
      # - request_date is a (more precise) Time instead of Date
      # - address is newline separated instead of coma (also more precise)
      def convert(raw)
        return build_fault(raw) if raw.key?('code')

        {
          address: format_address(raw.dig('target', 'address')),
          country_code: raw.dig('target', 'address', 'countryCode'),
          name: raw.dig('target', 'name'),
          vat_number: raw.dig('target', 'vatNumber'), valid: true
        }.tap do |hash|
          hash[:request_date] = Time.parse(raw['processingDate']) if raw.key?('processingDate')
          hash[:request_identifier] = raw['consultationNumber'] if raw.key?('consultationNumber')
        end
      end

      # Example raw address from the API:
      # {
      #   "line1": "HM REVENUE AND CUSTOMS",
      #   "line2": "RUBY HOUSE",
      #   "line3": "8 RUBY PLACE",
      #   "line4": "ABERDEEN",
      #   "postcode": "AB10 1ZP",
      #   "countryCode": "GB"
      # }
      def format_address(address)
        address&.values&.join("\n")
      end

      FAULTS = {
        'MESSAGE_THROTTLED_OUT' => RateLimitError,
        'SCHEDULED_MAINTENANCE' => ServiceUnavailable,
        'SERVER_ERROR' => ServiceUnavailable,
        'INVALID_REQUEST' => InvalidRequester,
        'GATEWAY_TIMEOUT' => Timeout
      }.freeze

      def build_fault(raw)
        fault = raw['code']
        return { valid: false } if fault == 'NOT_FOUND'

        exception = FAULTS[fault] || UnknownLookupError
        { error: exception.new("#{fault}#{raw['message'] ? " (#{raw['message']})" : ''}", self.class) }
      end
    end
  end
end
