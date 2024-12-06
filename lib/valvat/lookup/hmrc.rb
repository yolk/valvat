# frozen_string_literal: true

require_relative 'base'
require_relative '../hmrc/access_token'
require 'net/http'
require 'json'
require 'time'

class Valvat
  class Lookup
    class HMRC < Base
      PRODUCTION_ENDPOINT_URL = 'https://api.service.hmrc.gov.uk/organisations/vat/check-vat-number/lookup'
      SANDBOX_ENDPOINT_URL = 'https://test-api.service.hmrc.gov.uk/organisations/vat/check-vat-number/lookup'
      HEADERS = {
        # https://developer.service.hmrc.gov.uk/api-documentation/docs/reference-guide#versioning
        'Accept' => 'application/vnd.hmrc.2.0+json'
      }.freeze

      def perform
        return { valid: false } unless @options[:uk].is_a?(Hash) &&
                                       @options.dig(:uk, :client_id) &&
                                       @options.dig(:uk, :client_secret)

        parse(fetch(endpoint_uri).body)
      rescue Valvat::HMRC::AccessToken::Error => e
        { error: e }
      end

      private

      def endpoint_uri
        endpoint = "/#{@vat.to_s_wo_country}"
        endpoint += "/#{@requester.to_s_wo_country}" if @requester
        endpoint_url = @options.dig(:uk, :live) ? PRODUCTION_ENDPOINT_URL : SANDBOX_ENDPOINT_URL
        URI.parse(endpoint_url + endpoint)
      end

      def build_request(uri)
        Net::HTTP::Get.new(uri.request_uri, build_headers!)
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
        'GATEWAY_TIMEOUT' => Timeout,
        'INVALID_CREDENTIALS' => AuthorizationError
      }.freeze

      def build_fault(raw)
        fault = raw['code']
        return { valid: false } if fault == 'NOT_FOUND'

        exception = FAULTS[fault] || UnknownLookupError
        { error: exception.new("#{fault}#{raw['message'] ? " (#{raw['message']})" : ''}", self.class) }
      end

      def build_headers!
        HEADERS.merge('Authorization' => "Bearer #{fetch_access_token!}")
      end

      def fetch_access_token!
        @fetch_access_token ||= Valvat::HMRC::AccessToken.fetch(@options)
      end
    end
  end
end
