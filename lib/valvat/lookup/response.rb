# frozen_string_literal: true

class Valvat
  class Lookup
    class Response
      def initialize(raw)
        @raw = raw
      end

      def [](key)
        to_hash[key]
      end

      def to_hash
        @to_hash ||= self.class.cleanup(@raw.to_hash)
      end

      def self.cleanup(hash)
        (
          hash[:check_vat_approx_response] || hash[:check_vat_response] || {}
        ).each_with_object({}) do |(key, value), result|
          result[cleanup_key(key)] = cleanup_value(value) unless key == :"@xmlns"
        end
      end

      TRADER_PREFIX = /\Atrader_/.freeze

      def self.cleanup_key(key)
        key.to_s.sub(TRADER_PREFIX, '').to_sym
      end

      def self.cleanup_value(value)
        value == '---' ? nil : value
      end
    end
  end
end
