class Valvat
  module Lookup
    class Request
      def initialize(vat)
        @vat = vat
      end

      def perform(client)
        client.request("n1", action) do
          soap.body = body
          soap.namespaces["xmlns:n1"] = "urn:ec.europa.eu:taxud:vies:services:checkVat:types"    
        end.to_hash[response_key]
      end

      private

      def body
        {"n1:countryCode" => @vat.vat_country_code, "n1:vatNumber" => @vat.to_s_wo_country}
      end

      def action
        "checkVat"
      end

      def response_key
        :check_vat_response
      end
    end
  end
end