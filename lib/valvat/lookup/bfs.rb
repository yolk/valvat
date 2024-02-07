# frozen_string_literal: true

require_relative 'base'
require 'date'
require 'net/http'
require 'erb'
require 'rexml'

class Valvat
  class Lookup
    class BFS < Base
      # https://www.bfs.admin.ch/bfs/en/home/registers/enterprise-register/enterprise-identification/uid-register/uid-interfaces.html#-125185306
      # https://www.bfs.admin.ch/bfs/fr/home/registres/registre-entreprises/numero-identification-entreprises/registre-ide/interfaces-ide.assetdetail.11007266.html
      ENDPOINT_URI = URI('https://www.uid-wse-a.admin.ch/V5.0/PublicServices.svc').freeze
      HEADERS = {
        'Accept' => 'text/xml;charset=UTF-8',
        'Content-Type' => 'text/xml;charset=UTF-8',
        'SOAPAction' => 'http://www.uid.admin.ch/xmlns/uid-wse/IPublicServices/ValidateVatNumber'
      }.freeze

      BODY = <<-XML.gsub(/^\s+/, '')
        <soapenv:Envelope
        xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:uid="http://www.uid.admin.ch/xmlns/uid-wse">
          <soapenv:Header/>
          <soapenv:Body>
            <uid:ValidateVatNumber>
              <uid:vatNumber><%= Valvat::Lookup::BFS.prepare_for_lookup(@vat.to_s) %></uid:vatNumber>
              </uid:ValidateVatNumber>
          </soapenv:Body>
        </soapenv:Envelope>
      XML
      BODY_TEMPLATE = ERB.new(BODY).freeze

      def self.prepare_for_lookup(vat)
        # BFS requires a space between the VAT number and the suffix (if present)
        index_of_suffix = vat =~ /MWST|IVA|TVA/
        return if !index_of_suffix

        vat.insert(index_of_suffix, ' ')
      end

      def perform
        return { valid: false } unless @options[:ch]

        # BFS responds with a 500 if input is invalid, fault code is Data_validation_failed
        response = fetch(endpoint_uri)

        case [response, response.body]
        in [Net::HTTPSuccess, _]
          parse(response.body)
        in [Net::HTTPServerError, /Data_validation_failed/]
          parse(response.body)
        else
          { error: Valvat::HTTPError.new(response.code, self.class) }
        end
      end

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
        elements = doc.get_elements('/s:Envelope/s:Body').first.first
        convert_values(elements.each_with_object({}) do |el, hash|
          hash[convert_key(el.name)] = el.text
        end)
      end

      def convert_key(key)
        key.gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .downcase
           .to_sym
      end

      def convert_values(hash)
        return build_fault(hash) if hash[:faultstring]

        is_valid = case hash[:validate_vat_number_result]
                        when 'true' then true
                        when 'false' then false
                        else nil
                       end

        { valid: is_valid }
      end

      FAULTS = {
        'securityFaultFault' => SecurityError,
        'businessFaultFault' => BusinessError,
        'infrastructureFaultFault' => InfrastructureError,
      }.freeze

      def build_fault(hash)
        fault = hash[:faultstring]
        return hash.merge({ valid: false }) if fault == 'Data_validation_failed'

        hash.merge({ error: (FAULTS[fault] || UnknownLookupError).new(fault, self.class) })
      end
    end
  end
end
