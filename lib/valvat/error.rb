# frozen_string_literal: true

class Valvat
  Error = Class.new(RuntimeError)

  class LookupError < Error
    def initialize(faultstring = 'UNKNOWN', exception = nil)
      @faultstring = faultstring || exception.inspect
      @exception = exception
      super(faultstring)
    end

    def to_s
      "The web service returned the error '#{@faultstring}'."
    end

    def eql?(other)
      to_s.eql?(other.to_s)
    end
  end
  MaintenanceError = Class.new(LookupError)

  ServiceUnavailable = Class.new(MaintenanceError)
  MemberStateUnavailable = Class.new(MaintenanceError)

  Timeout = Class.new(LookupError)
  InvalidRequester = Class.new(LookupError)
  BlockedError = Class.new(LookupError)
  RateLimitError = Class.new(LookupError)

  UnknownLookupError = Class.new(LookupError)

  class HTTPError < LookupError
    def initialize(response)
      @response = response
      super('HTTP_ERROR')
    end

    def to_s
      "The VIES web service returned the HTTP status code #{@response.code}."
    end
  end
end
