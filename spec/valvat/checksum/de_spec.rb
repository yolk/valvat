# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Checksum::DE do
  %w[DE280857971 DE281381706 DE283108332 DE813622378 DE813628528 DE814178359 DE811907980].each do |valid_vat|
    it "returns true on valid VAT #{valid_vat}" do
      expect(Valvat::Checksum.validate(valid_vat)).to be(true)
    end

    invalid_vat = "#{valid_vat[0..-3]}#{valid_vat[-1]}#{valid_vat[-2]}"

    it "returns false on invalid VAT #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
    end
  end
end
