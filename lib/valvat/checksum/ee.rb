# frozen_string_literal: true

class Valvat
  module Checksum
    class EE < Base
      def check_digit
        multipliers = [7, 3, 1, 7, 3, 1, 7, 3]

        sum = sum_figures_by do |digit, index|
          digit * multipliers[index]
        end

        ((sum / 10.0).ceil * 10).to_i - sum
      end
    end
  end
end
