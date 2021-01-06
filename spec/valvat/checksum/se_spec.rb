# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Checksum::SE do
  %w[SE136695975501 SE556464687401 SE502052817901 SE556555952201 SE556084097601].each do |valid_vat|
    it "returns true on valid VAT #{valid_vat}" do
      expect(Valvat::Checksum.validate(valid_vat)).to be(true)
    end

    invalid_vat = "#{valid_vat[0..-4]}#{valid_vat[-1]}#{valid_vat[-2]}#{valid_vat[-3]}"

    it "returns false on invalid VAT #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
    end
  end

  it 'returns false on special case invalid VAT SE556464687400' do
    expect(Valvat::Checksum.validate('SE556464687400')).to be(false)
  end
end
