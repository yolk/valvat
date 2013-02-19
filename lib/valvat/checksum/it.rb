require 'valvat/checksum'

class Valvat
  module Checksum
    class IT < Base
      def validate
        y = figures_str[7..9].to_i
        y >= 1 && (y <= 100 || [120, 121].include?(y)) &&
        figures_str[0..6] != "0000000" &&
        super
      end

      def check_digit
        chk = 10 - figures.reverse.each_with_index.map do |fig, i|
          (fig*(i.modulo(2) == 0 ? 2 : 1)).to_s.split("").inject(0) { |sum, n| sum + n.to_i }
        end.inject(:+).modulo(10)
        chk
      end
    end
  end
end