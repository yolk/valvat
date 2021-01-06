# frozen_string_literal: true

class Valvat
  module Checksum
    class SE < Base
      check_digit_length 0

      def validate
        vat.to_s_wo_country[-2..-1].to_i.positive? &&
          super
      end

      private

      def check_digit
        sum_of_figures_for_at_es_it_se.modulo(10)
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
