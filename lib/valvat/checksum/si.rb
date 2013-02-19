require 'valvat/checksum'

class Valvat
  module Checksum
    class SI < Base
      def validate
        figures_str.to_i > 999999 &&
        super
      end

      def check_digit
        chk = 11 - figures.reverse.each_with_index.map do |fig, i|
          fig*(i+2)
        end.inject(:+).modulo(11)
        chk == 1 ? 0 : chk
      end
    end
  end
end