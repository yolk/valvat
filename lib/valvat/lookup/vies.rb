# frozen_string_literal: true

require_relative 'base'
require 'date'
require 'net/http'
require 'erb'
require 'rexml'

class Valvat
  class Lookup
    class VIES < Base
      ENDPOINT_URI = URI('https://ec.europa.eu/taxation_customs/vies/services/checkVatService').freeze
      HEADERS = {
        'Accept' => 'text/xml;charset=UTF-8',
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
                <urn:requesterCountryCode><%= @requester.vat_country_code %></urn:requesterCountryCode>
                <urn:requesterVatNumber><%= @requester.to_s_wo_country %></urn:requesterVatNumber>
                <% end %>
            </urn:checkVat<%= 'Approx' if @requester %>>
          </soapenv:Body>
        </soapenv:Envelope>
      XML
      BODY_TEMPLATE = ERB.new(BODY).freeze
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

      private

      def endpoint_uri
        ENDPOINT_URI
      end

      def build_request(uri)
        request = Net::HTTP::Post.new(uri.request_uri, HEADERS)
        request.body = BODY_TEMPLATE.result(binding)
        request
      end

      def parse(body)
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

      def build_fault(hash)
        fault = hash[:faultstring]
        return hash.merge({ valid: false }) if fault == 'INVALID_INPUT'

        hash.merge({ error: (FAULTS[fault] || UnknownLookupError).new(fault, self.class) })
      end
    end
  end
end
