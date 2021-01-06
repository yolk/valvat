# frozen_string_literal: true

class Valvat
  module Checksum
    class BG < Base
      def check_digit
        natural_person? ? check_digit_natural_person : check_digit_legal_person
      end

      def check_digit_natural_person
        local_person_chk = check_digit_local_natural_person

        return local_person_chk if given_check_digit == local_person_chk

        check_digit_foreign_natural_person
      end

      def check_digit_local_natural_person
        weight = [2, 4, 8, 5, 10, 9, 7, 3, 6]
        chk = figures.map do |fig|
          fig * weight.shift
        end.inject(:+).modulo(11)

        return chk if chk < 10

        0
      end

      def check_digit_foreign_natural_person
        weight = [21, 19, 17, 13, 11, 9, 7, 3, 1]

        figures.map do |fig|
          fig * weight.shift
        end.inject(:+).modulo(10)
      end

      def check_digit_legal_person
        chk = build_prod % 11

        if chk == 10
          chk = build_prod(3) % 11
          chk = 0 if chk == 10
        end

        chk
      end

      def build_prod(add = 1)
        prod = 0
        figures.each_with_index do |fig, index|
          prod += (index + add) * fig.to_i
        end
        prod
      end

      def natural_person?
        vat.to_s_wo_country.length == 10
      end
    end
  end
end
