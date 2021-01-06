# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Checksum::SI do
  %w[SI59082437 SI51049406 SI86154575 SI47431857 SI22511822 SI26833921].each do |valid_vat|
    it "returns true on valid VAT #{valid_vat}" do
      expect(Valvat::Checksum.validate(valid_vat)).to be(true)
    end

    invalid_vat = "#{valid_vat[0..-2]}#{valid_vat[-1].to_i + 1}"

    it "returns false on invalid VAT #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
    end
  end

  it 'returns false on special case invalid VAT SI11111107' do
    expect(Valvat::Checksum.validate('SI11111107')).to be(false)
  end

  it 'returns false on special case invalid VAT SI01111108' do
    expect(Valvat::Checksum.validate('SI01111108')).to be(false)
  end
end
