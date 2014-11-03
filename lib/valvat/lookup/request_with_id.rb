class Valvat
  class Lookup
    class RequestWithId < Request
      def initialize(vat, requester_vat)
        @vat = vat
        @requester_vat = requester_vat
      end

      private

      def body
        super.merge(
          :requester_country_code => @requester_vat.vat_country_code,
          :requester_vat_number => @requester_vat.to_s_wo_country
        )
      end

      def message_tag
        :checkVatApprox
      end

      def action
        :check_vat_approx
      end

      def response_key
        :check_vat_approx_response
      end
    end
  end
end