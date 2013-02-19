require 'valvat/checksum'

class Valvat
  module Checksum
    class ES < Base
      def check_digit
        natural_person? || natural_foreign_person? ?
          check_digit_natural_person :
          check_digit_legal_person
      end

      NATURAL_PERSON_CHARS = %w(T R W A G M Y F P D X B N J Z S Q V H L C K E)
      LEGAL_FOREIGN_PERSON_CHARS = %w(XXX A B C D E F G H I J)

      def check_digit_natural_person
        NATURAL_PERSON_CHARS[figures_str.to_i.modulo(23)]
      end

      def given_check_digit
        natural_person? || legal_foreign_person? || natural_foreign_person? ? str_wo_country[-1] : super
      end

      def check_digit_legal_person
        chk = 10 - figures.reverse.each_with_index.map do |fig, i|
          (fig*(i.modulo(2) == 0 ? 2 : 1)).to_s.split("").inject(0) { |sum, n| sum + n.to_i }
        end.inject(:+).modulo(10)
        legal_foreign_person? ? LEGAL_FOREIGN_PERSON_CHARS[chk] : chk
      end

      def str_wo_country
        if natural_person?
          super
        else
          super[1..-1]
        end
      end

      def natural_person?
        !!(vat.to_s_wo_country =~ /\A[\d]{8}[ABCDEFGHJKLMNPQRSTVWXYZ]\Z/)
      end

      def legal_foreign_person?
        !!(vat.to_s_wo_country =~ /\A[NPQRSW][\d]{7}[ABCDEFGHIJ]\Z/)
      end

      def natural_foreign_person?
        !!(vat.to_s_wo_country =~ /\A[KLMX][\d]{7}[ABCDEFGHJKLMNPQRSTVWXYZ]\Z/)
      end
    end
  end
end