# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Checksum::GB do
  %w[GBGD100 GBHA600].each do |gov_agency_vat|
    it "returns true on valid VAT for government agency #{gov_agency_vat}" do
      expect(Valvat::Checksum.validate(gov_agency_vat)).to be true
    end
  end

  %w[GB000000000 GB000000000000].each do |invalid_vat|
    it 'is false for all zero number' do
      expect(Valvat::Checksum.validate(invalid_vat)).to be false
    end
  end

  it 'is true for an old format valid vat' do
    expect(Valvat::Checksum.validate('GB434031494')).to be true
  end

  it 'is true for a new format valid vat' do
    expect(Valvat::Checksum.validate('GB434031439')).to be true
  end

  it 'is false for an old format VAT in forbidden group' do
    expect(Valvat::Checksum.validate('GB999999973')).to be false
  end

  it 'is false for a new format VAT in forbidden group' do
    expect(Valvat::Checksum.validate('GB100000034')).to be false
  end
end
