class Valvat
  Error = Class.new(RuntimeError)

  class ViesError < Error
    def initialize(faultstring)
      @faultstring = faultstring
    end

    def to_s
      "The VIES web service returned '#{@faultstring}'."
    end
  end

  ServiceUnavailable = Class.new(ViesError)
  MemberStateUnavailable = Class.new(ViesError)
  Timeout = Class.new(ViesError)

  InvalidRequester = Class.new(ViesError)
  BlockedError = Class.new(ViesError)
  RateLimitError = Class.new(ViesError)

  UnknownViesError = Class.new(ViesError)
end