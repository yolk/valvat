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
        begin
          Response.new(
            client.call(action, message: message, message_tag: message_tag)
          )
        rescue Savon::SOAPFault => fault
          Fault.new(fault)
        end
      end

      private

      def client
        Savon::Client.new({
          wsdl: VIES_WSDL_URL, log: false, follow_redirects: true
        }.merge(@options[:savon] || {}))
      end

      def message
        {
          country_code: @vat.vat_country_code,
          vat_number: @vat.to_s_wo_country
        }.merge(@requester ? {
            requester_country_code: @requester.vat_country_code,
            requester_vat_number: @requester.to_s_wo_country
          } : {}
        )
      end

      def message_tag
        @requester ? :checkVatApprox : :checkVat
      end

      def action
        @requester ? :check_vat_approx : :check_vat
      end
    end
  end
end