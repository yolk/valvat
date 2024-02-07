# frozen_string_literal: true

require 'singleton'

class Valvat
  ##
  # Configuration options should be set by passing a hash:
  #
  #   Valvat.configure(
  #     uk: true
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
      uk: false,

      # Use lookup via BFS for VAT numbers from the Switzerland
      # if set to false lookup will always return false for CH VAT numbers
      ch: false
    }.freeze

    def self.initialize
      instance.send(:initialize)
    end

    def [](key)
      @data[key]
    end

    def configure(options)
      @data = @data.merge(Utils.deep_symbolize_keys(options))
    end

    def initialize
      @data = DEFAULTS.clone
    end
  end
end
