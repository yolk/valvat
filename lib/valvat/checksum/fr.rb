# frozen_string_literal: true

class Valvat
  module Checksum
    class FR < Base
      # the valid characters for the first two digits (O and I are missing)
      ALPHABET = '0123456789ABCDEFGHJKLMNPQRSTUVWXYZ'
      NUMERIC = /^\d+$/.freeze

      def validate
        return super if str_wo_country[0..1] =~ NUMERIC

        check = alt_check_digit

        (str_wo_country[2..].to_i + 1 + (check / 11)) % 11 == check % 11
      end

      private

      def check_digit
        siren = str_wo_country[2..].to_i
        (12 + ((3 * siren) % 97)) % 97
      end

      def given_check_digit
        str_wo_country[0..1].to_i
      end

      def alt_check_digit
        first_is_numeric = str_wo_country[0] =~ NUMERIC

        (ALPHABET.index(str_wo_country[0]) * (first_is_numeric ? 24 : 34)) +
          ALPHABET.index(str_wo_country[1]) - (first_is_numeric ? 10 : 100)
      end
    end
  end
end
