module Valvat
  module Utils
    
    COUNTRY_PATTERN = /\A([A-Z]{2})(.+)\Z/
    
    def self.split(vat)
      COUNTRY_PATTERN =~ vat 
      [$1, $2]
    end
    
    def self.normalize(vat)
      vat.upcase.gsub(/\A\s+|\s+\Z/, "")
    end
  end
end