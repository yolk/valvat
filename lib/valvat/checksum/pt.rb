# frozen_string_literal: true

class Valvat
  module Checksum
    class PT < Base
      def check_digit
        chk = sum_of_figues_for_pt_si
        chk > 9 ? 0 : chk
      end
    end
  end
end
