# frozen_string_literal: true

class Valvat
  module Checksum
    class GB < Base
      OLD_FORMAT_FORBIDDEN_RANGES = [(100_000..999_999), (9_490_001..9_700_000), (9_990_001..9_999_999)].freeze
      NEW_FORMAT_FORBIDDEN_RANGES = [(1..100_000), (100_001..1_000_000)].freeze
      GOV_NUMBER = /\A(GD[0-4]{1}\d{2})\Z/.freeze
      HEALTH_NUMBER = /\A(HA[5-9]{1}\d{2})\Z/.freeze

      def validate # rubocop:disable Metrics/CyclomaticComplexity
        # government departments and health authorities, so no checksum
        return true if gov_or_health?
        return false if all_zero?

        return false if old_format_remainder.zero? && fobidden_in_old_format?
        return false if new_format_remainder.zero? && fobidden_in_new_format?

        old_format_remainder.zero? || new_format_remainder.zero?
      end

      private

      def checksum
        @checksum ||= str_wo_country[7..8].to_i
      end

      def vat_base
        @vat_base ||= str_wo_country[0..6]
      end

      def gov_or_health?
        str_wo_country =~ GOV_NUMBER || str_wo_country =~ HEALTH_NUMBER
      end

      def all_zero?
        str_wo_country =~ /\A0{9}\Z/ || str_wo_country =~ /\A0{12}\Z/
      end

      def vat_base_sum
        @vat_base_sum ||= vat_base.split('')
                                  .map(&:to_i)
                                  .zip([8, 7, 6, 5, 4, 3, 2])
                                  .map { |vat_number_digit, multiplier| vat_number_digit * multiplier }
                                  .inject(:+)
      end

      def old_format_remainder
        @old_format_remainder ||= (vat_base_sum + checksum).modulo(97)
      end

      def new_format_remainder
        @new_format_remainder ||= (vat_base_sum + 55 + checksum).modulo(97)
      end

      def fobidden_in_new_format?
        vat_base_int = vat_base.to_i
        NEW_FORMAT_FORBIDDEN_RANGES.any? { |range| range.include?(vat_base_int) }
      end

      def fobidden_in_old_format?
        vat_base_int = vat_base.to_i
        OLD_FORMAT_FORBIDDEN_RANGES.any? { |range| range.include?(vat_base_int) }
      end
    end
  end
end
