# frozen_string_literal: true

require 'net/http'
require_relative '../options'

class Valvat
  class Lookup
    class Base
      def initialize(vat, options = {})
        @vat = Valvat(vat)
        @options = Valvat::Options(options)
        @requester = @options[:requester] && Valvat(@options[:requester])
        @rate_limit = @options[:rate_limit]
      end

      def perform
        response = fetch(endpoint_uri)

        case response
        when Net::HTTPSuccess
          parse(response.body)
        else
          { error: Valvat::HTTPError.new(response.code, self.class) }
        end
      end

      private

      def endpoint_uri
        raise NotImplementedError
      end

      def build_request(uri)
        raise NotImplementedError
      end

      def parse(body)
        raise NotImplementedError
      end

      def fetch(uri, limit = 0)
        response = send_request(uri)

        if response == Net::HTTPRedirection && limit < @rate_limit
          fetch(URI.parse(response['Location']), limit + 1)
        else
          response
        end
      rescue Errno::ECONNRESET, IOError
        raise if limit > @rate_limit

        fetch(uri, limit + 1)
      end

      def send_request(uri)
        request = build_request(uri)

        Net::HTTP.start(uri.host, uri.port, options_for(uri)) do |http|
          http.request(request)
        end
      end

      def options_for(uri)
        @options[:http].merge({ use_ssl: URI::HTTPS === uri })
      end
    end
  end
end
