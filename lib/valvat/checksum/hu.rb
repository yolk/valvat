# frozen_string_literal: true

class Valvat
  module Checksum
    class HU < Base
      def check_digit
        multipliers = [3, 7, 9, 1, 3, 7, 9]

        sum = sum_figures_by do |digit, index|
          digit * multipliers[index]
        end

        (10 - sum % 10) % 10
      end
    end
  end
end
