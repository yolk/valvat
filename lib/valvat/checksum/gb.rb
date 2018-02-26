class Valvat
  module Checksum
    class GB < Base
      OLD_FORMAT_FORBIDDEN_RANGES = [(100_000..999_999), (9_490_001..9_700_000), (9_990_001..9_999_999)]
      NEW_FORMAT_FORBIDDEN_RANGES = [(1..100_000), (100_001..1_000_000)]

      def validate
        vat_number = vat.to_s_wo_country
        check_sum  = vat.to_s_wo_country[7..8].to_i
        vat_base = vat_number[0..6]

        # government departments and health authorities, so no checksum
        return true if vat_number =~ /\A(GD[0-4]{1}\d{2})\Z/ || vat_number =~ /\A(HA[5-9]{1}\d{2})\Z/
        return false if vat_number =~ /\A0{9}\Z/ || vat_number =~ /\A0{12}\Z/

        vat_base_sum = vat_base.split('').
          map(&:to_i).
          zip([8, 7, 6, 5, 4, 3, 2]).
          map { |vat_number_digit, multiplier| vat_number_digit * multiplier }.
          inject(:+)

        old_format_remainder = (vat_base_sum + check_sum).modulo(97)
        new_format_remainder = (vat_base_sum + 55 + check_sum).modulo(97)

        return false if old_format_remainder == 0 &&
          OLD_FORMAT_FORBIDDEN_RANGES.any? { |range| range.include? vat_base.to_i }

        return false if new_format_remainder == 0 &&
          NEW_FORMAT_FORBIDDEN_RANGES.any? { |range| range.include? vat_base.to_i }

        old_format_remainder == 0 || new_format_remainder == 0
      end
    end
  end
end
