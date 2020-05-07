class Valvat
  class Lookup
    class Response
      def initialize(raw)
        @raw = raw
        @hash = self.class.cleanup_hash(raw.to_hash)
      end

      def [](key)
        @hash[key]
      end

      def to_hash
        @hash
      end

      private

      def self.cleanup_hash(hash)
        (hash[:check_vat_approx_response] || hash[:check_vat_response] || {}).inject({}) do |hash, kv|
          key, value = kv
          unless key == :"@xmlns"
            hash[key.to_s.sub(/\Atrader_/, "").to_sym] = (value == "---" ? nil : value)
          end
          hash
        end
      end
    end
  end
end