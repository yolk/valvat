# frozen_string_literal: true

class Valvat
  module Checksum
    class FR < Base
      def check_digit
        siren = str_wo_country[2..-1].to_i
        (12 + (3 * siren) % 97) % 97
      end

      def given_check_digit
        str_wo_country[0..1].to_i
      end
    end
  end
end
