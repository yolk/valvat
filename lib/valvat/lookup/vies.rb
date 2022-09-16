# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'erb'

class Valvat
  class Lookup
    class Vies
      SERVICE_URL = 'https://ec.europa.eu/taxation_customs/vies/services/checkVatService'
      HEADERS = {
        'Content-Type' => 'text/xml;charset=UTF-8',
        'SOAPAction' => ''
      }.freeze

      BODY = <<-XML.gsub(/^\s+/, '')
        <soapenv:Envelope
        xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:urn="urn:ec.europa.eu:taxud:vies:services:checkVat:types">
          <soapenv:Header/>
          <soapenv:Body>
            <urn:checkVat<%= 'Approx' if @requester %>>
                <urn:countryCode><%= @vat.vat_country_code %></urn:countryCode>
                <urn:vatNumber><%= @vat.to_s_wo_country %></urn:vatNumber>
                <% if @requester %>
                <urn:requesterCountryCode><%= @vat.vat_country_code %></urn:requesterCountryCode>
                <urn:requesterVatNumber><%= @vat.to_s_wo_country %></urn:requesterVatNumber>
                <% end %>
            </urn:checkVat<%= 'Approx' if @requester %>>
          </soapenv:Body>
        </soapenv:Envelope>
      XML
      BODY_TEMPLATE = ERB.new(BODY).freeze

      def initialize(vat, options = {})
        @vat = Valvat(vat)
        @options = options
        @requester = @options[:requester] && Valvat(@options[:requester])
      end

      def perform
        response = fetch(URI.parse(@options[:vies_url] || SERVICE_URL))

        case response
        when Net::HTTPSuccess
          parse_xml(response.body)
        else
          { error: Valvat::HTTPError.new(response) }
        end
      end

      private

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
        request = Net::HTTP::Post.new(uri.request_uri, HEADERS)
        request.body = BODY_TEMPLATE.result(binding)

        options = (@options[:vies] || {}).merge({ use_ssl: URI::HTTPS === uri })

        Net::HTTP.start(uri.host, uri.port, options) do |http|
          http.request(request)
        end
      end

      def parse_xml(body)
        doc = REXML::Document.new(body)
        elements = doc.get_elements('/env:Envelope/env:Body').first.first
        convert_values(elements.each_with_object({}) do |el, hash|
          hash[convert_key(el.name)] = convert_value(el.text)
        end)
      end

      def convert_key(key)
        key.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .tr('-', '_')
           .sub(/\Atrader_/, '')
           .downcase.to_sym
      end

      def convert_value(value)
        value == '---' ? nil : value
      end

      def convert_values(hash)
        return build_fault(hash) if hash[:faultstring]

        hash[:valid] = hash[:valid] == 'true' || (hash[:valid] == 'false' ? false : nil) if hash.key?(:valid)
        hash[:request_date] = Date.parse(hash[:request_date]) if hash.key?(:request_date)
        hash
      end

      FAULTS = {
        'SERVICE_UNAVAILABLE' => ServiceUnavailable,
        'MS_UNAVAILABLE' => MemberStateUnavailable,
        'INVALID_REQUESTER_INFO' => InvalidRequester,
        'TIMEOUT' => Timeout,
        'VAT_BLOCKED' => BlockedError,
        'IP_BLOCKED' => BlockedError,
        'GLOBAL_MAX_CONCURRENT_REQ' => RateLimitError,
        'GLOBAL_MAX_CONCURRENT_REQ_TIME' => RateLimitError,
        'MS_MAX_CONCURRENT_REQ' => RateLimitError,
        'MS_MAX_CONCURRENT_REQ_TIME' => RateLimitError
      }.freeze

      def build_fault(hash)
        fault = hash[:faultstring]
        return hash.merge({ valid: false }) if fault == 'INVALID_INPUT'

        hash.merge({ error: (FAULTS[fault] || UnknownViesError).new(fault) })
      end
    end
  end
end
