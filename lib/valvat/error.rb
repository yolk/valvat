# frozen_string_literal: true

class Valvat
  Error = Class.new(RuntimeError)

  class ViesError < Error
    def initialize(faultstring = 'UNKNOWN', exception = nil)
      @faultstring = faultstring || exception.inspect
      @exception = exception
      super(faultstring)
    end

    def to_s
      "The VIES web service returned the error '#{@faultstring}'."
    end

    def eql?(other)
      to_s.eql?(other.to_s)
    end
  end
  ViesMaintenanceError = Class.new(ViesError)

  ServiceUnavailable = Class.new(ViesMaintenanceError)
  MemberStateUnavailable = Class.new(ViesMaintenanceError)

  Timeout = Class.new(ViesError)
  InvalidRequester = Class.new(ViesError)
  BlockedError = Class.new(ViesError)
  RateLimitError = Class.new(ViesError)

  UnknownViesError = Class.new(ViesError)

  class HTTPError < ViesError
    def initialize(response)
      @response = response
      super('HTTP_ERROR')
    end

    def to_s
      "The VIES web service returned the HTTP status code #{@response.code}."
    end
  end
end
