# frozen_string_literal: true

class Valvat
  class Lookup
    class Fault < Response
      def to_hash
        @to_hash ||= case @raw
        when Savon::HTTPError
          { error: HTTPError.new(nil, @raw) }
        when Savon::UnknownOperationError
          { error: OperationUnknown.new(nil, @raw) }
        else
          fault = @raw.to_hash[:fault][:faultstring]

          if fault == 'INVALID_INPUT'
            { valid: false }
          else
            error = (FAULTS[fault] || UnknownViesError).new(fault)
            { error: error }
          end
        end
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
    end
  end
end
