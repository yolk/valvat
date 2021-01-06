# frozen_string_literal: true

class Valvat
  module Checksum
    class BE < Base
      check_digit_length 2

      def check_digit
        97 - figures_str.to_i.modulo(97)
      end
    end
  end
end
