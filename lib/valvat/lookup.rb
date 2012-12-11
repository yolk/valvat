require 'valvat'
require 'net/http'
require 'yaml'

class Valvat
  module Lookup

    def self.validate(vat, options={})
      vat = Valvat(vat)
      return false unless vat.european?

      request = options[:requester_vat] ?
        Valvat::Lookup::RequestWithId.new(vat, Valvat(options[:requester_vat])) :
        Valvat::Lookup::Request.new(vat)

      begin
        response = request.perform(self.client)
        response[:valid] && (options[:detail] || options[:requester_vat]) ?
          filter_detail(response) : response[:valid]
      rescue => err
        if err.respond_to?(:to_hash) && err.to_hash[:fault] && (err.to_hash[:fault][:faultstring] || "").upcase =~ /INVALID_INPUT/
          return false
        end
        raise err if options[:raise_error]
        nil
      end
    end

    def self.client
      @client ||= begin
        # Require Savon only if really needed!
        require 'savon' unless defined?(Savon)

        # Quiet down Savon and HTTPI
        Savon.configure do |config|
          config.log = false
        end
        HTTPI.log = false

        Savon::Client.new('http://ec.europa.eu/taxation_customs/vies/checkVatService.wsdl')
      end
    end

    private

    REMOVE_KEYS = [:valid, :@xmlns]

    def self.filter_detail(response)
      response.inject({}) do |hash, kv|
        key, value = kv
        unless REMOVE_KEYS.include?(key)
          hash[key.to_s.sub(/^trader_/, "").to_sym] = (value == "---" ? nil : value)
        end
        hash
      end
    end
  end
end
