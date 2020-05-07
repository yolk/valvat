require 'savon'

class Valvat
  class Lookup
    class Request
      VIES_WSDL_URL = 'https://ec.europa.eu/taxation_customs/vies/checkVatService.wsdl'

      def initialize(vat, options)
        @vat = vat
        @options = options || {}
        @options[:requester_vat] &&= Valvat(@options[:requester_vat])
        @options[:wsdl] ||= VIES_WSDL_URL
      end

      def perform
        client = Savon::Client.new(wsdl: @options[:wsdl], log: false, follow_redirects: true)
        response = client.call(action, :message => body, :message_tag => message_tag).to_hash
        response[response_key]
      end

      private

      def body
        body = {:country_code => @vat.vat_country_code, :vat_number => @vat.to_s_wo_country}
        body.merge!(
          :requester_country_code => @options[:requester_vat].vat_country_code,
          :requester_vat_number => @options[:requester_vat].to_s_wo_country
        ) if @options[:requester_vat]
        body
      end

      def message_tag
        @options[:requester_vat] ? :checkVatApprox : :checkVat
      end

      def action
        @options[:requester_vat] ? :check_vat_approx : :check_vat
      end

      def response_key
        @options[:requester_vat] ? :check_vat_approx_response : :check_vat_response
      end
    end
  end
end