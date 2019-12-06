class Valvat
  module Checksum
    class NL < Base
      def validate
        vat.to_s.gsub(/[A-Z]/) { |let| (let.ord - 55).to_s }.to_i % 97 == 1 ||
        super
      end

      def check_digit
        sum_figures_by do |fig, i|
          fig*(i+2)
        end.modulo(11)
      end

      def str_wo_country
        super[0..-4]
      end
    end
  end
end