# frozen_string_literal: true

class Valvat
  module Checksum
    class DE < Base
      M = 10
      N = 11

      def check_digit
        prod = M
        figures.each do |fig|
          sum = (prod + fig).modulo(M)
          sum = M if sum.zero?
          prod = (2 * sum).modulo(N)
        end
        chk = N - prod
        chk == 10 ? 0 : chk
      end
    end
  end
end
