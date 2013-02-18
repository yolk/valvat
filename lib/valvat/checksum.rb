require 'valvat'

class Valvat
  module Checksum
    ALGORITHMS = {
      "DE" => lambda{|vat|
        m, n = 10, 11
        prod, sum = m, 0
        figures = vat.to_s_wo_country.split("").map(&:to_i)
        figures[0..7].each do |fig|
          sum = (prod + fig).modulo(m)
          sum = m if sum == 0
          prod = (2*sum).modulo(n)
        end
        chk = n - prod
        chk = 0 if chk == 10
        chk == figures.last
      }
    }

    def self.validate(vat)
      vat = Valvat(vat)
      algo = ALGORITHMS[vat.iso_country_code]
      !!(algo.nil? || algo.call(vat))
    end
  end
end