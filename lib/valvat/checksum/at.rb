require 'valvat/checksum'

class Valvat
  module Checksum
    class AT < Base
      def check_digit
        chk = 96 - figures.reverse.each_with_index.map do |fig, i|
          (fig*(i.modulo(2) == 0 ? 1 : 2)).to_s.split("").inject(0) { |sum, n| sum + n.to_i }
        end.inject(:+)
        chk.to_s[-1].to_i
      end

      def str_wo_country
        super[1..-1]
      end
    end
  end
end