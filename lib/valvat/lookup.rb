require 'valvat'
require 'net/http'
require 'yaml'

class Valvat
  class Lookup
    VIES_WSDL_URL = 'http://ec.europa.eu/taxation_customs/vies/checkVatService.wsdl'
    REMOVE_KEYS = [:valid, :@xmlns]

    attr_reader :vat, :options

    def initialize(vat, options={})
      @vat = Valvat(vat)
      @options = options || {}
      @options[:requester_vat] = Valvat(requester_vat) if requester_vat
    end

    def validate
      return false unless vat.european?

      valid? && show_details? ? response_details : valid?
    rescue => error
      return false if invalid_input?(error)
      raise error  if options[:raise_error]
      nil
    end

    class << self
      def validate(vat, options={})
        new(vat, options).validate
      end

      def client
        @client ||= begin
          # Require Savon only if really needed!
          require 'savon' unless defined?(Savon)

          Savon::Client.new(
            wsdl: VIES_WSDL_URL,
            # Quiet down Savon and HTTPI
            log: false
          )
        end
      end
    end

    private

    def valid?
      response[:valid]
    end

    def response
      @response ||= request.perform(self.class.client)
    end

    def request
      if requester_vat
        RequestWithId.new(vat, requester_vat)
      else
        Request.new(vat)
      end
    end

    def requester_vat
      options[:requester_vat]
    end

    def invalid_input?(err)
      return if !err.respond_to?(:to_hash) || !err.to_hash[:fault]
      (err.to_hash[:fault][:faultstring] || "").upcase =~ /INVALID_INPUT/
    end

    def show_details?
      requester_vat || options[:detail]
    end

    def response_details
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
