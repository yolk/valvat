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

      valid? && show_details? ? response.to_hash : valid?
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
  end
end
