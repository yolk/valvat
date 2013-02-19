require 'valvat/checksum'

class Valvat
  module Checksum
    class NL < Base
      def check_digit
        figures.reverse.each_with_index.map do |fig, i|
          fig*(i+2)
        end.inject(:+).modulo(11)
      end

      def str_wo_country
        super[0..-4]
      end
    end
  end
end