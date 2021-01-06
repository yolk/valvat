# frozen_string_literal: true

class Valvat
  module Checksum
    class LT < Base
      def check_digit
        base_checksum    = sum_with(0) % 11
        shifted_checksum = sum_with(2) % 11

        [base_checksum, shifted_checksum, 0].find { |checksum| checksum % 11 != 10 }
      end

      private

      def sum_with(offset)
        sum_figures_by do |digit, index|
          multi_digit_multiplier = figures.size - index + offset
          digit * (multi_digit_multiplier > 9 ? multi_digit_multiplier % 9 : multi_digit_multiplier)
        end
      end
    end
  end
end
