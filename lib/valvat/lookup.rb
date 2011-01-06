require 'valvat/utils'
require 'net/http'
require 'yaml'

module Valvat
  module Lookup
    def self.validate(vat)
      parts = Valvat::Utils.split(vat)
      return false unless parts[0]
      
      YAML.load(Net::HTTP.start("isvat.appspot.com", 80) {|http|
        http.get("/#{parts.join("/")}/")
      }.body)
    rescue
      nil
    end
  end
end