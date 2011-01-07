require 'valvat/utils'
require 'net/http'
require 'yaml'

module Valvat
  module Lookup
    def self.validate(vat)
      parts = Valvat::Utils.split(vat)
      return false unless parts[0]
      
      result = begin
        YAML.load(Net::HTTP.start("isvat.appspot.com", 80) {|http|
          http.get("/#{parts.join("/")}/")
        }.body)
      rescue
        nil
      end
      
      result.is_a?(Hash) && result["error_code"] == 1 ? nil : result
    end
  end
end