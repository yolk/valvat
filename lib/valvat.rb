class Valvat
  def initialize(raw)
    @raw = raw || ""
    @vat_country_code, @to_s_wo_country = to_a
  end
  
  attr_reader :raw, :vat_country_code, :to_s_wo_country
  
  def valid?
    Valvat::Syntax.validate(self)
  end
  
  def exists?
    Valvat::Lookup.validate(self)
  end
  alias_method :exist?, :exists?
  
  def iso_country_code
    Valvat::Utils.vat_country_to_iso_country(vat_country_code)
  end
  
  def european?
    Valvat::Utils::EU_COUNTRIES.include?(iso_country_code)
  end
  
  def to_a
    Valvat::Utils.split(raw)
  end
  
  def to_s
    raw
  end
  
  def inspect
    "#<Valvat #{[raw, iso_country_code].compact.join(" ")}>"
  end
end

def Valvat(vat)
  vat.is_a?(Valvat) ? vat : Valvat.new(vat)
end

require 'valvat/utils'
require 'valvat/syntax'
require 'valvat/lookup'
require 'valvat/version'
require 'valvat/active_model' if defined?(ActiveModel)
