# frozen_string_literal: true

class Valvat
  module Checksum
    class ES < Base
      NATURAL_PERSON_CHARS       = %w[T R W A G M Y F P D X B N J Z S Q V H L C K E].freeze
      NATURAL_PERSON_EXP         = /\A([KLMXYZ\d])/.freeze
      LEGAL_PERSON_CHARS = [false] + %w[A B C D E F G H I J]
      LEGAL_PERSON_EXP   = /\A[NPQRSW]\d{7}[ABCDEFGHIJ]\Z/.freeze
      NIE_DIGIT_BY_LETTER = %w[X Y Z].freeze

      def check_digit
        natural_person? ? check_digit_natural_person : check_digit_legal_person
      end

      def check_digit_natural_person
        letter = vat.to_s_wo_country[0]
        nie_digit = NIE_DIGIT_BY_LETTER.index(letter)
        NATURAL_PERSON_CHARS["#{nie_digit}#{figures_str}".to_i.modulo(23)]
      end

      def check_digit_legal_person
        chk = 10 - sum_of_figures_for_at_es_it_se(reverse_ints: true).modulo(10)
        if legal_foreign_person?
          LEGAL_PERSON_CHARS[chk]
        else
          (chk == 10 ? 0 : chk)
        end
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
