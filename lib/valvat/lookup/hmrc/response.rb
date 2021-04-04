# frozen_string_literal: true

class Valvat
  class Lookup
    module HMRC
      class Response
        FAULTS = {
          'MESSAGE_THROTTLED_OUT' => RateLimitError,
          'SCHEDULED_MAINTENANCE' => ServiceUnavailable,
          'SERVER_ERROR' => ServiceUnavailable,
          'INVALID_REQUEST' => InvalidRequester,
          'GATEWAY_TIMEOUT' => Timeout,
        }.freeze

        def initialize(raw)
          @raw = raw
        end

        def [](key)
          to_hash[key]
        end

        def to_hash
          @to_hash ||= self.class.cleanup(@raw)
        end

        # Return a similar format to VIES
        # Main differences are:
        # - request_date is a (more precise) Time instead of Date
        # - address is newline separated instead of coma (also more precise)
        def self.cleanup(raw)
          if raw.key?("target")
            h = {
              address: address_format(raw.dig("target", "address")),
              country_code: raw.dig("target", "address", "countryCode"),
              name: raw.dig("target", "name"),
              vat_number: raw.dig("target", "vatNumber"),
              valid: true
            }
            h[:request_date] = Time.parse(raw["processingDate"]) if raw.key?("processingDate")
            h[:request_identifier] = raw["consultationNumber"] if raw.key?("consultationNumber")
            h
          elsif raw["code"] == "NOT_FOUND"
            { valid: false }
          else
            code = raw["code"]
            exception = FAULTS[code] || UnknownLookupError
            { error: exception.new("The HMRC web service returned the error '#{code}' (#{raw["message"]}).") }
          end
        end

        # Example raw address from the API:
        # {
        #   "line1": "HM REVENUE AND CUSTOMS",
        #   "line2": "RUBY HOUSE",
        #   "line3": "8 RUBY PLACE",
        #   "line4": "ABERDEEN",
        #   "postcode": "AB10 1ZP",
        #   "countryCode": "GB"
        # }
        def self.address_format(address)
          address&.values&.join("\n")
        end
      end
    end
  end
end