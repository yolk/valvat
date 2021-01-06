# frozen_string_literal: true

class Valvat
  module Checksum
    class GR < Base
      def check_digit
        chk = sum_figures_by do |fig, i|
          fig * (2**(i + 1))
        end.modulo(11)
        chk > 9 ? 0 : chk
      end
    end
  end
end
