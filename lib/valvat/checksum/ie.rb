# frozen_string_literal: true

class Valvat
  module Checksum
    class IE < Base
      def check_digit
        total = sum_figures_by do |fig, i|
          fig * (i + 2)
        end
        total += ((CHARS.index(str_wo_country[8]) || 0) * 9) if str_wo_country.size == 9
        total.modulo(23)
      end

      CHARS = 'WABCDEFGHIJKLMNOPQRSTUV'.split('')

      def given_check_digit
        if str_wo_country.size == 9
          CHARS.index(str_wo_country[7])
        else
          CHARS.index(given_check_digit_str)
        end
      end

      def str_wo_country
        str = super
        # Convert old irish vat format to new one
        if str =~ /\A[0-9][A-Z][0-9]{5}[A-Z]\Z/
          "0#{str[2..6]}#{str[0]}#{str[7]}"
        else
          str
        end
      end

      def figures_str
        if super.size == 8
          super[0...-1]
        else
          super
        end
      end
    end
  end
end
