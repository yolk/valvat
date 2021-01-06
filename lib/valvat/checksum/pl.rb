# frozen_string_literal: true

class Valvat
  module Checksum
    class PL < Base
      def check_digit
        weight = [6, 5, 7, 2, 3, 4, 5, 6, 7]
        figures.map do |fig|
          fig * weight.shift
        end.inject(:+).modulo(11)
      end
    end
  end
end
