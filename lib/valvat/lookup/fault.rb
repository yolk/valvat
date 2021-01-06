# frozen_string_literal: true

class Valvat
  class Lookup
    class Fault < Response
      def self.cleanup(hash)
        fault = hash[:fault][:faultstring]
        return { valid: false } if fault == 'INVALID_INPUT'

        { error: fault_to_error(fault) }
      end

      FAULTS = {
        'SERVICE_UNAVAILABLE' => ServiceUnavailable,
        'MS_UNAVAILABLE' => MemberStateUnavailable,
        'INVALID_REQUESTER_INFO' => InvalidRequester,
        'TIMEOUT' => Timeout,
        'VAT_BLOCKED' => BlockedError,
        'IP_BLOCKED' => BlockedError,
        'GLOBAL_MAX_CONCURRENT_REQ' => RateLimitError,
        'GLOBAL_MAX_CONCURRENT_REQ_TIME' => RateLimitError,
        'MS_MAX_CONCURRENT_REQ' => RateLimitError,
        'MS_MAX_CONCURRENT_REQ_TIME' => RateLimitError
      }.freeze

      def self.fault_to_error(fault)
        (FAULTS[fault] || UnknownViesError).new(fault)
      end
    end
  end
end
