require 'spec_helper'

begin
  require File.dirname(__FILE__) + '/../../tmp/valid_vat_numbers.rb'
rescue LoadError
  VALID_VAT_NUMBERS = []
end

describe Valvat::Checksum do
  describe "#validate" do
    it "returns true on vat number with unknown checksum algorithm" do
      Valvat::Checksum.validate("FR99123543267").should eql(true)
    end

    it "returns false on corrupt number (e.g checks syntax)" do
      Valvat::Checksum.validate("FI1234567891").should eql(false)
    end

    VALID_VAT_NUMBERS.each do |valid_vat|
      it "returns true on valid vat number #{valid_vat}" do
        Valvat::Checksum.validate(valid_vat).should eql(true)
      end
    end
  end
end