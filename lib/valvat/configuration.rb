# frozen_string_literal: true

require 'singleton'

class Valvat
  ##
  # Configuration options should be set by passing a hash:
  #
  #   Valvat.configure(
  #     uk: { client_id: '<client_id>', client_secret: '<client_secret>' }
  #   )
  #
  def self.configure(options)
    Configuration.instance.configure(options) unless options.nil?
  end

  # Read-only access to config
  def self.config
    Configuration.instance
  end

  class Configuration
    include Singleton

    DEFAULTS = {
      # Set to true to always raise error, even on temporary maintenance downtime errors,
      # set to false to suppress all errors and return nil instead
      raise_error: nil,

      # Set options for the http client.
      # These options are directly passed to `Net::HTTP.start`
      http: {}.freeze,

      # Return details hash on lookup instead of boolean
      detail: false,

      # Your own VAT number used on lookup
      requester: nil,

      # Skip local validation on lookup
      skip_local_validation: false,

      # Use lookup via HMRC for VAT numbers from the UK
      # if set to false lookup will always return false for UK VAT numbers
      # HMRC options:
      # - API credentials for OAuth 2.0 Authentication
      # - Live mode for switching between Sandbox and Production API:
      # * TRUE - Production API
      # * FALSE - Sandbox API
      # See more details https://developer.service.hmrc.gov.uk/api-documentation/docs/development-practices
      uk: {
        live: true,
        client_id: nil,
        client_secret: nil
      }.freeze,

      # Rate limit for Lookup and HMRC Authentication requests
      rate_limit: 5
    }.freeze

    def self.initialize
      instance.send(:initialize)
    end

    def [](key)
      @data[key]
    end

    def dig(*keys)
      @data.dig(*keys)
    end

    def configure(options)
      @data = @data.deep_merge(Utils.deep_symbolize_keys(options))
    end

    def initialize
      @data = DEFAULTS.clone
    end
  end
end
