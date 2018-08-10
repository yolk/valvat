require 'valvat/local'
require 'valvat/lookup'
require 'valvat/lookup/request'
require 'valvat/lookup/request_with_id'
require 'active_model/validations/valvat_validator' if defined?(ActiveModel)

class Valvat
  def exists?(options={})
    Valvat::Lookup.validate(self, options)
  end
  alias_method :exist?, :exists?
end
