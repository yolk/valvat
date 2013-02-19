require 'valvat/checksum'

class Valvat
  module Checksum
    class PT < Base
      def check_digit
        chk = 11 - figures.reverse.each_with_index.map do |fig, i|
          fig*(i+2)
        end.inject(:+).modulo(11)
        chk > 9 ? 0 : chk
      end
    end
  end
end