require 'valvat/checksum'

class Valvat
  module Checksum
    class AT < Base
      include AlgorythmHelper

      def check_digit
        chk = 96 - sum_of_figures
        chk.to_s[-1].to_i
      end

      def str_wo_country
        super[1..-1]
      end
    end
  end
end