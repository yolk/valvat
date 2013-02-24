class Valvat
  module Checksum
    class BG < Base
      def check_digit
        natural_person? ? check_digit_natural_person : check_digit_legal_person
      end
      
      def check_digit_natural_person
        weight = [2, 4, 8, 5, 10, 9, 7, 3, 6]
        chk = figures.map do |fig|
          fig * weight.shift
        end.inject(:+).modulo(11)
        
        return chk if chk < 10
        return 0
      end
      
      def check_digit_legal_person
        prod = 0
        figures.each_with_index do |fig, index|
          prod += (index + 1) * fig.to_i
        end
        
        chk = prod % 11
        
        if chk == 10
          prod = 0
          figures.each_with_index do |fig, index|
            prod += (index + 3) * fig.to_i
          end
          
          chk = prod % 11
          chk = 0 if chk == 10
        end
        
        chk
      end
      
      def natural_person?
        vat.to_s_wo_country.length == 10
      end
    end
  end
end