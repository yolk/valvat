# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Checksum::IT do
  %w[IT12345670785 IT01897810162 IT00197200132 IT02762750210].each do |valid_vat|
    it "returns true on valid VAT #{valid_vat}" do
      expect(Valvat::Checksum.validate(valid_vat)).to be(true)
    end

    invalid_vat = "#{valid_vat[0..-3]}#{valid_vat[-1]}#{valid_vat[-2]}"

    it "returns false on invalid VAT #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
    end
  end

  it 'returns false on invalid special case VAT IT12345671783' do
    expect(Valvat::Checksum.validate('IT12345671783')).to be(false)
  end

  it 'returns false on invalid special case VAT IT00000000133' do
    expect(Valvat::Checksum.validate('IT00000000133')).to be(false)
  end
end
