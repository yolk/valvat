# frozen_string_literal: true

class Valvat
  Error = Class.new(RuntimeError)

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
  MaintenanceError = Class.new(LookupError)

  ServiceUnavailable = Class.new(MaintenanceError)
  MemberStateUnavailable = Class.new(MaintenanceError)

  Timeout = Class.new(LookupError)
  InvalidRequester = Class.new(LookupError)
  BlockedError = Class.new(LookupError)
  RateLimitError = Class.new(LookupError)

  UnknownLookupError = Class.new(LookupError)

  HTTPError = Class.new(LookupError)

  AuthorizationError = Class.new(LookupError)
end
