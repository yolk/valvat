require 'spec_helper'

begin
  require File.dirname(__FILE__) + '/../../tmp/valid_vat_numbers.rb'
rescue LoadError
  VALID_VAT_NUMBERS = []
end

describe Valvat::Checksum do
  describe "#validate" do
    it "returns true on VAT number with unknown checksum algorithm" do
      expect(Valvat::Checksum.validate("CZ699001237")).to eql(true)
    end

    it "returns false on corrupt number (e.g checks syntax)" do
      expect(Valvat::Checksum.validate("FI1234567891")).to eql(false)
    end

    VALID_VAT_NUMBERS.each do |valid_vat|
      it "returns true on valid VAT number #{valid_vat}" do
        expect(Valvat::Checksum.validate(valid_vat)).to eql(true)
      end
    end
  end
end