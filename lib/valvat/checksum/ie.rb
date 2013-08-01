require 'valvat/checksum'

class Valvat
  module Checksum
    class IE < Base
      def check_digit
        sum_figures_by do |fig, i|
          fig*(i+2)
        end.modulo(23)
      end

      CHARS = "WABCDEFGHIJKLMNOPQRSTUV".split("")

      def given_check_digit
        CHARS.index(given_check_digit_str)
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
    end
  end
end