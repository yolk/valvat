# frozen_string_literal: true

class Valvat
  class Error < RuntimeError
  end

  class LookupError < Error
    def initialize(message, kind)
      @message = message.to_s
      @kind = kind.is_a?(Class) ? kind.name.split('::').last : kind.to_s
      super(@message)
    end

    def to_s
      "The #{@kind} web service returned the error: #{@message}"
    end

    def eql?(other)
      to_s.eql?(other.to_s)
    end
  end

  class MaintenanceError < LookupError
  end

  class ServiceUnavailable < MaintenanceError
  end

  class MemberStateUnavailable < MaintenanceError
  end

  class Timeout < LookupError
  end

  class InvalidRequester < LookupError
  end

  class BlockedError < LookupError
  end

  class RateLimitError < LookupError
  end

  class UnknownLookupError < LookupError
  end

  class HTTPError < LookupError
  end

  class AuthorizationError < LookupError
  end
end
