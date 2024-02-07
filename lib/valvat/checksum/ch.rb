# frozen_string_literal: true

class Valvat
  module Checksum
    class CH < Base
      # All CH VAT starts with CHE. First figure is a character and should be skipped.
      # The CH VATs can have a suffix (MWST, TVA, IVA) which should be skipped.
      # Thus giving 8 figures to calculate the check digit
      FIGURES_RANGE = [1..8]
      CHECK_DIGIT_POS = 9

      def check_digit
        # https://www.ech.ch/sites/default/files/dosvers/hauptdokument/STAN_d_DEF_2021-07-02_eCH-0097_V5.2.0_Datenstandard%20Unternehmensidentifikation.pdf
        weight = [5, 4, 3, 2, 7, 6, 5, 4]

        chk = 11 - figures.map do |num|
          num * weight.shift
        end.inject(:+).modulo(11)

        chk == 11 ? 0 : chk
      end

      private

      def given_check_digit_str
        str_wo_country[CHECK_DIGIT_POS]
      end

      def figures_str
        str_wo_country[*FIGURES_RANGE]
      end
    end
  end
end
