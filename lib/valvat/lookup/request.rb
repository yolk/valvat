# frozen_string_literal: true

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
        Response.new(
          client.call(action, message: message, message_tag: message_tag)
        )
      rescue Savon::SOAPFault => e
        Fault.new(e)
      end

      private

      def client
        Savon::Client.new({
          wsdl: VIES_WSDL_URL, log: false, follow_redirects: true
        }.merge(@options[:savon] || {}))
      end

      def message
        add_requester({
                        country_code: @vat.vat_country_code,
                        vat_number: @vat.to_s_wo_country
                      })
      end

      def message_tag
        @requester ? :checkVatApprox : :checkVat
      end

      def action
        @requester ? :check_vat_approx : :check_vat
      end

      def add_requester(message)
        return message unless @requester

        message[:requester_country_code] = @requester.vat_country_code
        message[:requester_vat_number]   = @requester.to_s_wo_country

        message
      end
    end
  end
end
