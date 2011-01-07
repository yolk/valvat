class Valvat
  module Utils
    
    EU_COUNTRIES = %w(AT BE BG CY CZ DE DK EE ES FI FR GB GR HU IE IT LT LU LV MT NL PL PT RO SE SI SK)
    COUNTRY_PATTERN = /\A([A-Z]{2})(.+)\Z/
    
    def self.split(vat)
      COUNTRY_PATTERN =~ vat 
      result = [$1, $2]
      iso_country = vat_country_to_iso_country(result[0])
      EU_COUNTRIES.include?(iso_country) ? result : [nil, nil]
    end
    
    def self.normalize(vat)
      vat.upcase.gsub(/\A\s+|\s+\Z/, "")
    end
    
    def self.vat_country_to_iso_country(vat_country)
      vat_country == "EL" ? "GR" : vat_country
    end
  end
end