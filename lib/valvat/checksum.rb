# frozen_string_literal: true

class Valvat
  module Checksum
    class Base
      attr_reader :vat

      def self.check_digit_length(len = nil)
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
        str_wo_country[0..-(self.class.check_digit_length + 1)]
      end

      def figures
        figures_str.split('').map(&:to_i)
      end

      def str_wo_country
        vat.to_s_wo_country
      end

      def sum_figures_by(&block)
        figures.reverse.each_with_index.map(&block).inject(:+)
      end

      def sum_of_squares(num)
        num.to_s.split('').map(&:to_i).inject(:+)
      end

      def sum_of_figures_for_at_es_it_se(reverse_ints: false)
        ints = reverse_ints ? [2, 1] : [1, 2]
        sum_figures_by do |fig, i|
          sum_of_squares(fig * (i.modulo(2).zero? ? ints[0] : ints[1]))
        end
      end

      def sum_of_figues_for_pt_si
        11 - sum_figures_by do |fig, i|
          fig * (i + 2)
        end.modulo(11)
      end
    end

    def self.validate(vat)
      vat = Valvat(vat)
      algo = ALGORITHMS[vat.iso_country_code]
      Valvat::Syntax.validate(vat) && !!(algo.nil? || algo.new(vat).validate)
    end

    ALGORITHMS = Dir[File.join(__dir__, 'checksum', '*.rb')].each_with_object({}) do |path, algos|
      require path.gsub(/\.rb$/, '')

      classname = File.basename(path, '.rb').upcase
      algos[classname] = ['Valvat', 'Checksum', classname].inject(Object, :const_get)
    end.freeze
  end
end
