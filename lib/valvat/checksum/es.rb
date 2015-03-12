class Valvat
  module Checksum
    class ES < Base
      NATURAL_PERSON_CHARS       = %w(T R W A G M Y F P D X B N J Z S Q V H L C K E)
      NATURAL_PERSON_EXP         = /\A([\d]{8}[ABCDEFGHJKLMNPQRSTVWXYZ]|[KLMXYZ][\d]{7}[ABCDEFGHJKLMNPQRSTVWXYZ])\Z/
      LEGAL_PERSON_CHARS = [false] + %w(A B C D E F G H I J)
      LEGAL_PERSON_EXP   = /\A[NPQRSW][\d]{7}[ABCDEFGHIJ]\Z/

      def check_digit
        natural_person? ? check_digit_natural_person : check_digit_legal_person
      end

      def check_digit_natural_person
        nie_digit = nil
        letter = vat.to_s_wo_country[0]
        if letter == 'X'
          nie_digit = 0
        elsif letter == 'Y'
          nie_digit = 1
        elsif letter == 'Z'
          nie_digit = 2
        end
        NATURAL_PERSON_CHARS["#{nie_digit}#{figures_str}".to_i.modulo(23)]
      end

      def check_digit_legal_person
        chk = 10 - sum_of_figures_for_at_es_it_se(true).modulo(10)
        legal_foreign_person? ?
          LEGAL_PERSON_CHARS[chk] :
          (chk == 10 ? 0 : chk)
      end

      def given_check_digit
        person? ? str_wo_country[-1] : super
      end

      def str_wo_country
        str = super
        str[0] =~ /\d/ ? str : str[1..-1]
      end

      def person?
        natural_person? || legal_foreign_person?
      end

      def natural_person?
        !!(vat.to_s_wo_country =~ NATURAL_PERSON_EXP)
      end

      def legal_foreign_person?
        !!(vat.to_s_wo_country =~ LEGAL_PERSON_EXP)
      end
    end
  end
end