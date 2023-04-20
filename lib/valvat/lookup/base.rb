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

        if response == Net::HTTPRedirection && limit < 5
          fetch(URI.parse(response['Location']), limit + 1)
        else
          response
        end
      rescue Errno::ECONNRESET, IOError, OpenSSL::SSL::SSLError
        raise if limit > 5

        sleep(0.01)
        fetch(uri, limit + 1)
      end

      def send_request(uri)
        request = build_request(uri)

        Net::HTTP.start(uri.host, uri.port, options_for(uri)) do |http|
          http.request(request)
        end
      end

      def options_for(uri)
        options = if @options.key?(:savon)
                    puts 'DEPRECATED: The option :savon is deprecated. Use :http instead.'
                    @options[:savon]
                  else
                    @options[:http]
                  end || {}

        options.merge({ use_ssl: URI::HTTPS === uri })
      end
    end
  end
end
