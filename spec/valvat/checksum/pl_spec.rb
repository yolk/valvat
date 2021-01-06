# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Checksum::PL do
  %w[PL8567346215 PL5260211587 PL9720575348 PL5272650022].each do |valid_vat|
    it "returns true on valid VAT #{valid_vat}" do
      expect(Valvat::Checksum.validate(valid_vat)).to be(true)
    end

    invalid_vat = "#{valid_vat[0..-4]}#{valid_vat[-1]}#{valid_vat[-2]}#{valid_vat[-3]}"

    it "returns false on invalid VAT #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
    end
  end

  it 'returns false on special case invalid VAT PL8566445330' do
    expect(Valvat::Checksum.validate('PL8566445330')).to be(false)
  end
end
