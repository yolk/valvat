require 'valvat'
require 'net/http'
require 'yaml'

class Valvat
  module Lookup

    def self.validate(vat,full_details=false)
      vat = Valvat(vat)
      return false unless vat.european?

      begin
        response=client.request("n1", "checkVat") do
          soap.body = {"n1:countryCode" => vat.vat_country_code, "n1:vatNumber" => vat.to_s_wo_country}
          soap.namespaces["xmlns:n1"] = "urn:ec.europa.eu:taxud:vies:services:checkVat:types"
        end
        return response.to_hash[:check_vat_response] if full_details
        response.to_hash[:check_vat_response][:valid]
      rescue => err
        if err.respond_to?(:to_hash) && err.to_hash[:fault] && err.to_hash[:fault][:faultstring] == "{ 'INVALID_INPUT' }"
          return false
        end
        nil
      end
    end

    def self.validate_with_id(vat,requester_vat)
      vat = Valvat(vat)
      return false unless vat.european?
      
      requester_vat=Valvat(requester_vat)
      return false unless requester_vat.european?
      
      begin
        client.request("n1", "checkVatApprox") do
          soap.body = {"n1:countryCode" => vat.vat_country_code, "n1:vatNumber" => vat.to_s_wo_country, "n1:requesterCountryCode" => requester_vat.vat_country_code, "n1:requesterVatNumber" => requester_vat.to_s_wo_country}
          soap.namespaces["xmlns:n1"] = "urn:ec.europa.eu:taxud:vies:services:checkVat:types"
        end.to_hash[:check_vat_approx_response]
      rescue => err
        if err.respond_to?(:to_hash) && err.to_hash[:fault] && err.to_hash[:fault][:faultstring] == "{ 'INVALID_INPUT' }"
          return false
        end
        nil
      end
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
