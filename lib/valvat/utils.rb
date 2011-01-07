module Valvat
  module Utils
    
    COUNTRY_PATTERN = /\A([A-Z]{2})(.+)\Z/
    
    def self.split(vat)
      COUNTRY_PATTERN =~ vat 
      result = [$1, $2]
      result[0] = "GR" if result[0] == "EL"
      result
    end
    
    def self.normalize(vat)
      vat.upcase.gsub(/\A\s+|\s+\Z/, "")
    end
  end
end