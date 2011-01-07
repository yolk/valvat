module Valvat
  module Utils
    
    EU_COUNTRIES = %w(AT BE BG CY CZ DE DK EE ES FI FR GB GR HU IE IT LT LU LV MT NL PL PT RO SE SI SK)
    COUNTRY_PATTERN = /\A([A-Z]{2})(.+)\Z/
    
    def self.split(vat)
      COUNTRY_PATTERN =~ vat 
      result = [$1, $2]
      result[0] = "GR" if result[0] == "EL"
      return [nil, nil] unless EU_COUNTRIES.include?(result[0])
      result
    end
    
    def self.normalize(vat)
      vat.upcase.gsub(/\A\s+|\s+\Z/, "")
    end
  end
end