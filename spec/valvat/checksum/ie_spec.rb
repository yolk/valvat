# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Checksum::IE do
  %w[IE8473625E IE0123459N IE9B12345N IE1113571MH IE2973912UH IE2974611LH
     IE2974901UH IE3200115LH IE3206791MH IE3208913KH IE3214048CH].each do |valid_vat|
    it "returns true on valid VAT #{valid_vat}" do
      expect(Valvat::Checksum.validate(valid_vat)).to eql(true), valid_vat
    end

    invalid_vat = "#{valid_vat[0..-4]}#{valid_vat[-2]}#{valid_vat[-3]}#{valid_vat[-1]}"

    it "returns false on invalid VAT #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
    end
  end

  %w[IE0000000XX IE0000000AZ].each do |invalid|
    it "returns false on invalid VAT #{invalid}" do
      expect(Valvat::Checksum.validate(invalid)).to be(false)
    end
  end
end
