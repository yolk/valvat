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

      def given_check_digit
        vat.to_s_wo_country[-self.class.check_digit_length..-1].to_i
      end

      def figures_str
        vat.to_s_wo_country[0..-(self.class.check_digit_length+1)]
      end

      def figures
        figures_str.split("").map(&:to_i)
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

      def given_check_digit
        0
      end

      def check_digit
        weight = [2, 7, 6, 5, 4, 3, 2, 1]
        figures.map do |fig|
          fig * weight.shift
        end.inject(:+).modulo(11)
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
  end
end