# frozen_string_literal: true

class Valvat
  Error = Class.new(RuntimeError)

  class ViesError < Error
    def initialize(faultstring = 'UNKNOWN')
      @faultstring = faultstring
      super
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
end
