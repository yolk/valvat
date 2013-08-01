class Valvat
  class Lookup
    class Request
      def initialize(vat)
        @vat = vat
      end

      def perform(client)
        client.call(action, :message => body).to_hash[response_key]
      end

      private

      def body
        {:country_code => @vat.vat_country_code, :vat_number => @vat.to_s_wo_country}
      end

      def action
        :check_vat
      end

      def response_key
        :check_vat_response
      end
    end
  end
end