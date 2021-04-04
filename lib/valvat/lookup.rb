# frozen_string_literal: true

require_relative 'lookup/vies/request'
require_relative 'lookup/hmrc/request'

class Valvat
  class Lookup
    def initialize(vat, options = {})
      @vat = Valvat(vat)
      @options = options || {}
      @options[:requester] ||= @options[:requester_vat]
    end

    def validate
      return false if !@options[:skip_local_validation] && !@vat.valid?
      return handle_error(response[:error]) if response[:error]

      response[:valid] && show_details? ? response.to_hash : response[:valid]
    end

    class << self
      def validate(vat, options = {})
        new(vat, options).validate
      end
    end

    private

    def valid?
      response[:valid]
    end

    def response
      @response ||= case @vat.vat_country_code
      when 'GB' then HMRC::Request.new(@vat, @options).perform
      else VIES::Request.new(@vat, @options).perform
      end
    end

    def show_details?
      @options[:requester] || @options[:detail]
    end

    def handle_error(error)
      if error.is_a?(MaintenanceError)
        raise error if @options[:raise_error]
      else
        raise error unless @options[:raise_error] == false
      end
    end
  end
end
