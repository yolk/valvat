# frozen_string_literal: true

class Valvat
  module Checksum
    class CY < Base
      def check_digit
        odd_position_digit_values = [1, 0, 5, 7, 9, 13, 15, 17, 19, 21]

        sum = sum_figures_by do |digit, index|
          (8 - index).odd? ? odd_position_digit_values[digit] : digit
        end

        ('a'..'z').to_a[sum % 26]
      end

      def given_check_digit
        given_check_digit_str.downcase
      end
    end
  end
end
