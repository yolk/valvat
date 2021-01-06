# frozen_string_literal: true

class Valvat
  module Checksum
    class MT < Base
      check_digit_length 2

      def check_digit
        multipliers = [9, 8, 7, 6, 4, 3]

        sum = sum_figures_by { |digit, index| digit * multipliers[index] }

        supposed_checksum = 37 - (sum % 37)
        supposed_checksum.zero? ? 37 : supposed_checksum
      end
    end
  end
end
