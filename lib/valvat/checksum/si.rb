class Valvat
  module Checksum
    class SI < Base
      def validate
        figures_str.to_i > 999999 &&
        super
      end

      def check_digit
        chk = sum_of_figues_for_pt_si
        chk == 10 ? 0 : chk
      end
    end
  end
end
