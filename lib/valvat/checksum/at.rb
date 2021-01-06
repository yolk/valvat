# frozen_string_literal: true

class Valvat
  module Checksum
    class AT < Base
      def check_digit
        chk = 96 - sum_of_figures_for_at_es_it_se
        chk.to_s[-1].to_i
      end

      def str_wo_country
        super[1..-1]
      end
    end
  end
end
