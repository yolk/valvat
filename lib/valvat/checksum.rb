require 'valvat'

class Valvat
  module Checksum
    ALGORITHMS = {}

    def self.validate(vat)
      vat = Valvat(vat)
      algo = ALGORITHMS[vat.iso_country_code]
      !!(algo.nil? || algo.new(vat).validate)
    end

    class Base
      def self.inherited(klass)
        ALGORITHMS[klass.name.split(/::/).last] = klass
      end

      attr_reader :vat

      def self.check_digit_length(len=nil)
        @check_digit_length = len if len
        @check_digit_length || 1
      end

      def initialize(vat)
        @vat = vat
      end

      def validate
        check_digit == given_check_digit
      end

      private

      def given_check_digit_str
        str_wo_country[-self.class.check_digit_length..-1]
      end

      def given_check_digit
        given_check_digit_str.to_i
      end

      def figures_str
        str_wo_country[0..-(self.class.check_digit_length+1)]
      end

      def figures
        figures_str.split("").map(&:to_i)
      end

      def str_wo_country
        vat.to_s_wo_country
      end
    end

    class BE < Base
      check_digit_length 2

      def check_digit
        97 - figures_str.to_i.modulo(97)
      end
    end

    class DE < Base
      M = 10
      N = 11

      def check_digit
        prod = M
        figures.each do |fig|
          sum = (prod + fig).modulo(M)
          sum = M if sum == 0
          prod = (2*sum).modulo(N)
        end
        chk = N - prod
        chk == 10 ? 0 : chk
      end
    end

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

    class FI < Base
      def check_digit
        weight = [7, 9, 10, 5, 8, 4, 2]
        chk = 11 - figures.map do |fig|
          fig * weight.shift
        end.inject(:+).modulo(11)
        return false if chk == 10
        chk == 11 ? 0 : chk
      end
    end

    class GR < Base
      def check_digit
        chk = figures.reverse.each_with_index.map do |fig, i|
          fig*(2**(i+1))
        end.inject(:+).modulo(11)
        chk > 9 ? 0 : chk
      end
    end

    class IE < Base
      def check_digit
        figures.reverse.each_with_index.map do |fig, i|
          fig*(i+2)
        end.inject(:+).modulo(23)
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

    class IT < Base
      def validate
        y = figures_str[7..9].to_i
        y >= 1 && (y <= 100 || [120, 121].include?(y)) &&
        figures_str[0..6] != "0000000" &&
        super
      end

      def check_digit
        chk = 10 - figures.reverse.each_with_index.map do |fig, i|
          (fig*(i.modulo(2) == 0 ? 2 : 1)).to_s.split("").inject(0) { |sum, n| sum + n.to_i }
        end.inject(:+).modulo(10)
        chk
      end
    end

    class LU < Base
      check_digit_length 2

      def check_digit
        figures_str.to_i.modulo(89)
      end
    end

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