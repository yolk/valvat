# frozen_string_literal: true

class Valvat
  Error = Class.new(RuntimeError)

  LookupError = Class.new(Error)
  MaintenanceError = Class.new(LookupError)

  ServiceUnavailable = Class.new(MaintenanceError)
  MemberStateUnavailable = Class.new(MaintenanceError)

  Timeout = Class.new(LookupError)
  InvalidRequester = Class.new(LookupError)
  BlockedError = Class.new(LookupError)
  RateLimitError = Class.new(LookupError)

  UnknownLookupError = Class.new(LookupError)
end
