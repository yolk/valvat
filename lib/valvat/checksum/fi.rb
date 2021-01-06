# frozen_string_literal: true

class Valvat
  module Checksum
    class FI < Base
      def check_digit
        weight = [7, 9, 10, 5, 8, 4, 2]
        chk = 11 - figures.map do |fig|
          fig * weight.shift
        end.inject(:+).modulo(11)
        chk == 11 ? 0 : chk
      end
    end
  end
end
