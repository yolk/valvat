# frozen_string_literal: true

class Valvat
  module Checksum
    class RO < Base
      def check_digit
        multipliers = [2, 3, 5, 7, 1, 2, 3, 5, 7]

        sum = sum_figures_by { |digit, index| digit * multipliers[index] }
        sum * 10 % 11 % 10
      end

      def figures_str
        super.rjust(9, '0')
      end
    end
  end
end
