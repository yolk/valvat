# frozen_string_literal: true

class Valvat
  module Checksum
    class DK < Base
      check_digit_length 0

      def check_digit
        weight = [2, 7, 6, 5, 4, 3, 2, 1]
        figures.map do |fig|
          fig * weight.shift
        end.inject(:+).modulo(11)
      end

      def given_check_digit
        0
      end
    end
  end
end
