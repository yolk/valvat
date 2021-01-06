# frozen_string_literal: true

class Valvat
  def initialize(raw)
    @raw = Valvat::Utils.normalize(raw || '')
    @vat_country_code, @to_s_wo_country = to_a
  end

  attr_reader :raw, :vat_country_code, :to_s_wo_country

  def blank?
    raw.nil? || raw.strip == ''
  end

  def valid?
    Valvat::Syntax.validate(self)
  end

  def valid_checksum?
    Valvat::Checksum.validate(self)
  end

  def iso_country_code
    Valvat::Utils.vat_country_to_iso_country(vat_country_code)
  end

  # TODO: Remove method / not in use
  def european?
    Valvat::Utils::EU_MEMBER_STATES.include?(iso_country_code)
  end

  def to_a
    Valvat::Utils.split(raw)
  end

  def to_s
    raw
  end

  def inspect
    "#<Valvat #{[raw, iso_country_code].compact.join(' ')}>"
  end
end

def Valvat(vat) # rubocop:disable Naming/MethodName
  vat.is_a?(Valvat) ? vat : Valvat.new(vat)
end

require 'valvat/utils'
require 'valvat/syntax'
require 'valvat/checksum'
require 'valvat/version'
