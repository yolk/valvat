# frozen_string_literal: true

class Valvat
  module Checksum
    class ES < Base
      NATURAL_PERSON_CHARS       = %w[T R W A G M Y F P D X B N J Z S Q V H L C K E].freeze
      NATURAL_PERSON_EXP         = /\A[KLMXYZ\d]/.freeze
      LEGAL_PERSON_CHARS = [false] + %w[A B C D E F G H I J]
      NIE_DIGIT_BY_LETTER = %w[X Y Z].freeze
      GIVEN_CD_IS_A_LETTER_EXP   = /[A-Z]\Z/.freeze
      LEGAL_PERSON_EXP = /\A[ABCDEFGHJUVNPQRSW]/
      CIF_MUST_BE_A_LETTER_EXP = /\A[NPQRSW]/
      CIF_MUST_BE_A_NUMBER_EXP = /\A[HJUV]/
      SPECIAL_NIF_EXP = /\A[KLM]/

      def validate
        passes_special_validations? && possible_check_digits.include?(given_check_digit)
      end

      private

      def passes_special_validations?
        !(
          # [KLM]: CD first two numerical digits must be between 01 and 56 (both inclusive)
          vat.to_s_wo_country =~ SPECIAL_NIF_EXP &&
          vat.to_s_wo_country[1..2].to_i > 56 or vat.to_s_wo_country[1..2].to_i < 01 ||
          # Exceptions: X0000000T, 00000001R, 00000000T, 99999999R are invalid.
          %w[X0000000T 00000001R 00000000T 99999999R].include?(vat.to_s_wo_country)
        )
      end

      def given_check_digit
        given_cd_is_a_letter? ? str_wo_country[-1] : super
      end

      def possible_check_digits
        natural_person? ? possible_cd_natural_person : possible_cds_legal_person
      end

      def possible_cd_natural_person
        letter = vat.to_s_wo_country[0]
        nie_digit = NIE_DIGIT_BY_LETTER.index(letter)
        [NATURAL_PERSON_CHARS["#{nie_digit}#{figures_str}".to_i.modulo(23)]]
      end

      def possible_cds_legal_person
        chk = 10 - sum_of_figures_for_at_es_it_se(reverse_ints: true).modulo(10)
        possible_check_digits = []
        if cd_can_be_a_letter?
          possible_check_digits << LEGAL_PERSON_CHARS[chk]
        end
        if cd_can_be_a_num?
          possible_check_digits << (chk == 10 ? 0 : chk)
        end
        possible_check_digits
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
        !!(vat.to_s_wo_country =~ FOREIGN_LEGAL_PERSON_EXP)
      end

      def cd_can_be_a_letter?
        !(vat.to_s_wo_country =~ CIF_MUST_BE_A_NUMBER_EXP)
      end

      def cd_can_be_a_num?
        !(vat.to_s_wo_country =~ CIF_MUST_BE_A_LETTER_EXP)
      end

      def given_cd_is_a_letter?
        !!(vat.to_s_wo_country =~ GIVEN_CD_IS_A_LETTER_EXP)
      end
    end
  end
end
