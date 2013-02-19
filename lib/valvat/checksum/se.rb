require 'valvat/checksum'

class Valvat
  module Checksum
    class SE < Base
      check_digit_length 0

      def validate
        vat.to_s_wo_country[-2..-1].to_i > 0 &&
        super
      end

      private

      def check_digit
        figures.reverse.each_with_index.map do |fig, i|
          (fig*(i.modulo(2) == 0 ? 1 : 2)).to_s.split("").inject(0) { |sum, n| sum + n.to_i }
        end.inject(:+).modulo(10)
      end

      def given_check_digit
        0
      end

      def str_wo_country
        vat.to_s_wo_country[0..9]
      end
    end
  end
end