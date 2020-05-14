require 'savon'

class Valvat
  class Lookup
    class Request
      VIES_WSDL_URL = 'https://ec.europa.eu/taxation_customs/vies/checkVatService.wsdl'

      def initialize(vat, options)
        @vat = Valvat(vat)
        @options = options || {}
        @requester = @options[:requester] && Valvat(@options[:requester])
      end

      def perform
        client_options = {wsdl: VIES_WSDL_URL, log: false, follow_redirects: true}.merge(@options[:savon] || {})
        client = Savon::Client.new(client_options)
        begin
          Response.new(client.call(action, message: body, message_tag: message_tag))
        rescue Savon::SOAPFault => fault
          Fault.new(fault)
        end
      end

      private

      def body
        body = {country_code: @vat.vat_country_code, vat_number: @vat.to_s_wo_country}
        body.merge!(
          requester_country_code: @requester.vat_country_code,
          requester_vat_number: @requester.to_s_wo_country
        ) if @requester
        body
      end

      def message_tag
        @requester ? :checkVatApprox : :checkVat
      end

      def action
        @requester ? :check_vat_approx : :check_vat
      end

      def response_key
        @requester ? :check_vat_approx_response : :check_vat_response
      end
    end
  end
end