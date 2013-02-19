require 'valvat'

class Valvat
  module Checksum
    ALGORITHMS = {}

    def self.validate(vat)
      vat = Valvat(vat)
      algo = ALGORITHMS[vat.iso_country_code]
      Valvat::Syntax.validate(vat) && !!(algo.nil? || algo.new(vat).validate)
    end

    class Base
      def self.inherited(klass)
        ALGORITHMS[klass.name.split(/::/).last] = klass
      end

      attr_reader :vat

      def self.check_digit_length(len=nil)
        @check_digit_length = len if len
        @check_digit_length || 1
      end

      def initialize(vat)
        @vat = vat
      end

      def validate
        check_digit == given_check_digit
      end

      private

      def given_check_digit_str
        str_wo_country[-self.class.check_digit_length..-1]
      end

      def given_check_digit
        given_check_digit_str.to_i
      end

      def figures_str
        str_wo_country[0..-(self.class.check_digit_length+1)]
      end

      def figures
        figures_str.split("").map(&:to_i)
      end

      def str_wo_country
        vat.to_s_wo_country
      end
    end
  end
end

Dir[File.dirname(__FILE__) + "/checksum/*.rb"].each do |file|
  require file
end