class Valvat
  module Lookup
    class RequestWithId < Request
      def initialize(vat, requester_vat)
        @vat = vat
        @requester_vat = requester_vat
      end
      
      private
      
      def body
        super.merge(
          "n1:requesterCountryCode" => @requester_vat.vat_country_code, 
          "n1:requesterVatNumber" => @requester_vat.to_s_wo_country
        )
      end
      
      def action
        "checkVatApprox"
      end
      
      def response_key
        :check_vat_approx_response
      end
    end
  end
end