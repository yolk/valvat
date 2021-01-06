# frozen_string_literal: true

class Valvat
  module Checksum
    class LU < Base
      check_digit_length 2

      def check_digit
        figures_str.to_i.modulo(89)
      end
    end
  end
end
