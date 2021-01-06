# frozen_string_literal: true

class Valvat
  module Checksum
    class HR < Base
      def check_digit
        product = 10
        sum     = 0

        figures.each do |figure|
          sum = (figure + product) % 10
          sum = 10 if sum.zero?
          product = (2 * sum) % 11
        end

        (10 - (product - 1) % 10) % 10
      end
    end
  end
end
