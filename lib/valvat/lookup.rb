require 'valvat'
require 'net/http'
require 'yaml'

class Valvat
  module Lookup
    def self.validate(vat)
      vat = Valvat(vat)
      return false unless vat.european?
      result = begin
        YAML.load(Net::HTTP.start("isvat.appspot.com", 80) {|http|
          http.get("/#{vat.to_a.join("/")}/")
        }.body)
      rescue => err
        # Ugly, ugly for better specs
        raise if defined?(FakeWeb::NetConnectNotAllowedError) && FakeWeb::NetConnectNotAllowedError === err
        nil
      end
      
      result.is_a?(Hash) && result["error_code"] == 1 ? nil : result
    end
  end
end