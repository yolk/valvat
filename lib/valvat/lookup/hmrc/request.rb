# frozen_string_literal: true

require_relative 'response'
require 'net/http'

class Valvat
  class Lookup
    module HMRC
      class Request
        HMRC_API_URL = 'https://api.service.hmrc.gov.uk/organisations/vat/check-vat-number/lookup'

        def initialize(vat, options)
          @vat = Valvat(vat)
          @options = options || {}
          @requester = @options[:requester] && Valvat(@options[:requester])
          raise InvalidRequester.new("Requester must be a GB number when checking GB VAT numbers.") if @requester && @requester.vat_country_code != "GB"
        end

        def perform
          endpoint = "/#{@vat.to_s_wo_country}"
          endpoint += "/#{@requester.to_s_wo_country}" if @requester
          uri = URI.parse(HMRC_API_URL + endpoint)
          request = Net::HTTP::Get.new(uri)
          # https://developer.service.hmrc.gov.uk/api-documentation/docs/reference-guide#versioning
          request["Accept"] = "application/vnd.hmrc.1.0+json"
          response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
          Response.new(JSON.parse(response.body))
        rescue Net::HTTPExceptions, JSON::ParserError => e
          { error: e }
        end
      end
    end
  end
end
