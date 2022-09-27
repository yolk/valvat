# frozen_string_literal: true

require 'net/http'

class Valvat
  class Lookup
    class Base
      def initialize(vat, options = {})
        @vat = Valvat(vat)
        @options = options
        @requester = @options[:requester] && Valvat(@options[:requester])
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

        if Net::HTTPRedirection == response && limit < 5
          fetch(URI.parse(response['Location']), limit + 1)
        else
          response
        end
      rescue Errno::ECONNRESET
        raise if limit > 5

        fetch(uri, limit + 1)
      end

      def send_request(uri)
        request = build_request(uri)

        options = (@options[:http] || {}).merge({ use_ssl: URI::HTTPS === uri })

        Net::HTTP.start(uri.host, uri.port, options) do |http|
          http.request(request)
        end
      end
    end
  end
end
