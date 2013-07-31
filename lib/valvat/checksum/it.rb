require 'valvat/checksum'

class Valvat
  module Checksum
    class IT < Base
      include AlgorythmHelper

      def validate
        y = figures_str[7..9].to_i
        y >= 1 && (y <= 100 || [120, 121].include?(y)) &&
        figures_str[0..6] != "0000000" &&
        super
      end

      def check_digit
        chk = 10 - sum_of_figures(true).modulo(10)
        chk == 10 ? 0 : chk
      end
    end
  end
end