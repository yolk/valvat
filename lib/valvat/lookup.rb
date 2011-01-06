require 'valvat/utils'

module Valvat
  module Lookup
    
    def self.validate(vat)
      country_code, vat_number = Valvat::Utils.split(vat)
      response = client.request "n1", "checkVat" do
        soap.body = {"n1:countryCode" => country_code, "n1:vatNumber" => vat_number}
        soap.namespaces["xmlns:n1"] = "urn:ec.europa.eu:taxud:vies:services:checkVat:types"
      end
      response.to_hash[:check_vat_response][:valid]
    rescue => err
      false if err.to_hash[:fault] && err.to_hash[:faultstring] = 'INVALID_INPUT'
      nil
    end
    
    def self.client
      @client ||= begin
        # Require Savon only if really needed!
        require 'savon' unless defined?(Savon)
        
        # Quiet down Savon and HTTPI
        Savon.logger.level = Logger::WARN
        HTTPI.logger.level = Logger::WARN
        
        Savon::Client.new do
          wsdl.document = 'http://ec.europa.eu/taxation_customs/vies/checkVatService.wsdl'
        end
      end
    end
  end
end