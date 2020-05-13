class Valvat
  class Lookup

    def initialize(vat, options={})
      @vat = Valvat(vat)
      @options = options || {}
      @options[:requester] ||= @options[:requester_vat]
    end

    def validate
      return false if !@options[:skip_local_validation] && !@vat.valid?
      return handle_vies_error(response[:error]) if response[:error]

      response[:valid] && show_details? ? response.to_hash : response[:valid]
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
      @response ||= Request.new(@vat, @options).perform
    end

    def show_details?
      @options[:requester] || @options[:detail]
    end

    def handle_vies_error(fault)
      case fault
      when "INVALID_INPUT"
        false
      when "INVALID_REQUESTER_INFO"
        raise InvalidRequester.new(fault) unless @options[:raise_error] == false
      when "SERVICE_UNAVAILABLE"
        raise ServiceUnavailable.new(fault) if @options[:raise_error]
      when "MS_UNAVAILABLE"
        raise MemberStateUnavailable.new(fault) if @options[:raise_error]
      when "TIMEOUT"
        raise Timeout.new(fault) unless @options[:raise_error] == false
      when "VAT_BLOCKED", "IP_BLOCKED"
        raise BlockedError.new(fault) unless @options[:raise_error] == false
      when "GLOBAL_MAX_CONCURRENT_REQ", "GLOBAL_MAX_CONCURRENT_REQ_TIME",
           "MS_MAX_CONCURRENT_REQ", "MS_MAX_CONCURRENT_REQ_TIME"
        raise RateLimitError.new(fault) unless @options[:raise_error] == false
      else
        raise UnknownViesError.new(fault) unless @options[:raise_error] == false
      end
    end
  end
end
