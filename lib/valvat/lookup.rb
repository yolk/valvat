class Valvat
  class Lookup
    REMOVE_KEYS = [:valid, :@xmlns]

    attr_reader :vat, :options

    def initialize(vat, options={})
      @vat = Valvat(vat)
      @options = options || {}
    end

    def validate
      if !@options[:skip_local_validation] && !vat.valid?
        return false
      end

      handle_faults(valid? && show_details? ? response.to_hash : valid?)
    end

    class << self
      def validate(vat, options={})
        new(vat, options).validate
      end
    end

    private

    def valid?
      response[:valid]
    end

    def response
      @response ||= Request.new(vat, options).perform
    end

    def show_details?
      options[:requester_vat] || options[:detail]
    end

    def handle_faults(value)
      return value unless value.nil?
      case fault = response.to_hash[:fault]
      when "INVALID_INPUT"
      when "INVALID_REQUESTER_INFO"
        raise InvalidRequester.new(fault)
      when "SERVICE_UNAVAILABLE"
        raise ServiceUnavailable.new(fault) if @options[:raise_error]
      when "MS_UNAVAILABLE"
        raise MemberStateUnavailable.new(fault) if @options[:raise_error]
      when "TIMEOUT"
        raise Timeout.new(fault)
      when "VAT_BLOCKED", "IP_BLOCKED"
        raise BlockedError.new(fault)
      when "GLOBAL_MAX_CONCURRENT_REQ", "GLOBAL_MAX_CONCURRENT_REQ_TIME",
           "MS_MAX_CONCURRENT_REQ", "MS_MAX_CONCURRENT_REQ_TIME"
        raise RateLimitError.new(fault)
      else
        raise UnknownViesError.new(fault)
      end
      value
    end
  end
end
