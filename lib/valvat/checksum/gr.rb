require 'valvat/checksum'

class Valvat
  module Checksum
    class GR < Base
      def check_digit
        chk = figures.reverse.each_with_index.map do |fig, i|
          fig*(2**(i+1))
        end.inject(:+).modulo(11)
        chk > 9 ? 0 : chk
      end
    end
  end
end