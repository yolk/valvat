# frozen_string_literal: true

class Valvat
  module Checksum
    class IT < Base
      def validate
        y = figures_str[7..9].to_i
        y >= 1 && (y <= 100 || [120, 121].include?(y)) &&
          figures_str[0..6] != '0000000' &&
          super
      end

      def check_digit
        chk = 10 - sum_of_figures_for_at_es_it_se(reverse_ints: true).modulo(10)
        chk == 10 ? 0 : chk
      end
    end
  end
end
