# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Checksum::FR do
  %w[FR60528551658 FR43820567501 FR0H384498879].each do |valid_vat|
    it "returns true on valid VAT #{valid_vat}" do
      expect(Valvat::Checksum.validate(valid_vat)).to be(true)
    end

    invalid_vat = "#{valid_vat[0..-3]}#{valid_vat[-1]}#{valid_vat[-2]}"

    it "returns false on invalid VAT #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
    end
  end
end
