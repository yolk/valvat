# frozen_string_literal: true

class Valvat
  module Syntax
    VAT_PATTERNS = {
      'AT' => /\AATU[0-9]{8}\Z/,                                          # Austria
      'BE' => /\ABE[0-1][0-9]{9}\Z/,                                      # Belgium
      'BG' => /\ABG[0-9]{9,10}\Z/,                                        # Bulgaria
      'CY' => /\ACY(?!12)[0-59][0-9]{7}[A-Z]\Z/,                          # Cyprus
      'CZ' => /\ACZ[0-9]{8,10}\Z/,                                        # Czech Republic
      'DE' => /\ADE[0-9]{9}\Z/,                                           # Germany
      'DK' => /\ADK[0-9]{8}\Z/,                                           # Denmark
      'EE' => /\AEE10[0-9]{7}\Z/,                                         # Estonia
      'GR' => /\AEL[0-9]{9}\Z/,                                           # Greece
      'ES' => /\AES([A-Z][0-9]{8}|[0-9]{8}[A-Z]|[A-Z][0-9]{7}[A-Z])\Z/,   # Spain
      'FI' => /\AFI[0-9]{8}\Z/,                                           # Finland
      'FR' => /\AFR[A-HJ-NP-Z0-9]{2}[0-9]{9}\Z/,                          # France
      'GB' => /\A(GB|XI)([0-9]{9}|[0-9]{12}|(HA|GD)[0-9]{3})\Z/,          # United Kingdom
      'HR' => /\AHR[0-9]{11}\Z/,                                          # Croatia
      'HU' => /\AHU[0-9]{8}\Z/,                                           # Hungary
      'IE' => /\AIE([0-9][A-Z][0-9]{5}|[0-9]{7}[A-Z]?)[A-Z]\Z/,           # Ireland
      'IT' => /\AIT[0-9]{11}\Z/,                                          # Italy
      'LT' => /\ALT([0-9]{7}1[0-9]|[0-9]{10}1[0-9])\Z/,                   # Lithuania
      'LU' => /\ALU[0-9]{8}\Z/,                                           # Luxembourg
      'LV' => /\ALV[0-9]{11}\Z/,                                          # Latvia
      'MT' => /\AMT[0-9]{8}\Z/,                                           # Malta
      'NL' => /\ANL[0-9]{9}B[0-9]{2}\Z/,                                  # Netherlands
      'PL' => /\APL[0-9]{10}\Z/,                                          # Poland
      'PT' => /\APT[0-9]{9}\Z/,                                           # Portugal
      'RO' => /\ARO[1-9][0-9]{1,9}\Z/,                                    # Romania
      'SE' => /\ASE[0-9]{10}01\Z/,                                        # Sweden
      'SI' => /\ASI[0-9]{8}\Z/,                                           # Slovenia
      'SK' => /\ASK[0-9]{10}\Z/                                           # Slovakia
    }.freeze

    def self.validate(vat)
      vat = Valvat(vat)
      pattern = VAT_PATTERNS[vat.iso_country_code]
      !!(pattern && pattern =~ vat.to_s)
    end
  end
end
