# frozen_string_literal: true

require 'net/http'
require 'json'

class Valvat
  module HMRC
    class AccessToken
      Error = Class.new(StandardError)

      PRODUCTION_ENDPOINT_URL = 'https://api.service.hmrc.gov.uk/oauth/token'
      SANDBOX_ENDPOINT_URL = 'https://test-api.service.hmrc.gov.uk/oauth/token'
      SCOPE = 'read:vat'
      GRANT_TYPE = 'client_credentials'

      def initialize(options = {})
        uk_options = options[:uk].is_a?(Hash) ? options[:uk] : {}

        @client_id = uk_options[:client_id].to_s
        @client_secret = uk_options[:client_secret].to_s
        @rate_limit = options[:rate_limit]
        @endpoint_uri = URI(uk_options[:sandbox] ? SANDBOX_ENDPOINT_URL : PRODUCTION_ENDPOINT_URL)
      end

      def self.fetch(options = {})
        new(options).fetch
      end

      def fetch(uri = @endpoint_uri, request_count = 0)
        raise_if_invalid!

        request = build_request(uri)
        response = build_https.request(request)
        handle_response!(response, request_count)
      rescue Errno::ECONNRESET, IOError
        raise if request_count > @rate_limit

        fetch(uri, request_count + 1)
      end

      private

      def raise_if_invalid!
        raise Error, 'Client ID is missing' if @client_id.empty?
        raise Error, 'Client secret is missing' if @client_secret.empty?
      end

      def build_request(uri)
        request = Net::HTTP::Post.new(uri)
        request['Content-Type'] = 'application/x-www-form-urlencoded'
        request.body = build_body
        request
      end

      def build_body
        URI.encode_www_form(
          scope: SCOPE,
          grant_type: GRANT_TYPE,
          client_id: @client_id,
          client_secret: @client_secret
        )
      end

      def build_https
        https = Net::HTTP.new(@endpoint_uri.host, @endpoint_uri.port)
        https.use_ssl = true
        https
      end

      def parse_response!(response)
        JSON.parse(response.read_body)
      end

      def parse_response_location(response)
        URI.parse(response['Location'])
      end

      # See https://developer.service.hmrc.gov.uk/api-documentation/docs/authorisation/application-restricted-endpoints
      def handle_response!(response, request_count)
        if response.is_a?(Net::HTTPRedirection) && request_count < @rate_limit
          fetch(parse_response_location(response), request_count + 1)
        elsif response.code == '200'
          # {"access_token":"<access_token>","token_type":"bearer","expires_in":14400,"scope":"read:vat"}
          parse_response!(response)['access_token']
        else
          raise Error, "Failed to fetch access token: #{handle_response_error(response, request_count)}"
        end
      end

      def handle_response_error(response, request_count)
        if response.code.match?(/4\d\d/)
          # For 4xx codes: {"error":"invalid_client","error_description":"invalid client id or secret"}
          parse_response!(response)['error_description']
        elsif request_count >= @rate_limit
          'rate limit exceeded'
        else
          response.read_body
        end
      end
    end
  end
end
