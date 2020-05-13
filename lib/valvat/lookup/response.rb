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
        (hash[:check_vat_approx_response] || hash[:check_vat_response] || {}).inject({}) do |hash, (key, value)|
          hash[cleanup_key(key)] = cleanup_value(value) unless key == :"@xmlns"
          hash
        end
      end

      TRADER_PREFIX = /\Atrader_/

      def self.cleanup_key(key)
        key.to_s.sub(TRADER_PREFIX, "").to_sym
      end

      def self.cleanup_value(value)
        value == "---" ? nil : value
      end
    end
  end
end