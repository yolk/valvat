require 'valvat'

class Valvat
  module Checksum
    ALGORITHMS = {
      "BE" => lambda{ |vat|
        str = vat.to_s_wo_country
        (97 - str[0..-3].to_i.modulo(97)) == str[-2..-1].to_i
      },
      "DE" => lambda{ |vat|
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
      },
      "DK" => lambda{ |vat|
        weight = [2, 7, 6, 5, 4, 3, 2, 1]
        vat.to_s_wo_country.split("").map do |fig|
          fig.to_i * weight.shift
        end.inject(:+).modulo(11) == 0
      },
      "FI" => lambda{ |vat|
        weight = [7, 9, 10, 5, 8, 4, 2]
        r = 11 - vat.to_s_wo_country.split("")[0..-2].map do |fig|
          fig.to_i * weight.shift
        end.inject(:+).modulo(11)
        return false if r == 10
        r = 0 if r == 11
        r == vat.to_s_wo_country[-1].to_i
      }
    }

    def self.validate(vat)
      vat = Valvat(vat)
      algo = ALGORITHMS[vat.iso_country_code]
      !!(algo.nil? || algo.call(vat))
    end
  end
end