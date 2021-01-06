# frozen_string_literal: true

require 'valvat/error'
require 'valvat/local'
require 'valvat/lookup'
require 'valvat/lookup/request'
require 'valvat/lookup/response'
require 'valvat/lookup/fault'
require 'active_model/validations/valvat_validator' if defined?(ActiveModel)

class Valvat
  def exists?(options = {})
    Valvat::Lookup.validate(self, options)
  end
  alias exist? exists?
end
