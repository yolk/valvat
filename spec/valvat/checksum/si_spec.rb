require 'spec_helper'

describe Valvat::Checksum::SI do
  %w(SI59082437 SI51049406 SI86154575 SI47431857 SI22511822 SI22511880).each do |valid_vat|
    it "returns true on valid vat #{valid_vat}" do
      Valvat::Checksum.validate(valid_vat).should eql(true)
    end

    invalid_vat = "#{valid_vat[0..-5]}#{valid_vat[-1]}#{valid_vat[-4]}#{valid_vat[-3]}#{valid_vat[-2]}"

    it "returns false on invalid vat #{invalid_vat}" do
      Valvat::Checksum.validate(invalid_vat).should eql(false)
    end
  end

  it "returns false on special case invalid vat SI11111107" do
    Valvat::Checksum.validate("SI11111107").should eql(false)
  end

  it "returns false on special case invalid vat SI01111108" do
    Valvat::Checksum.validate("SI01111108").should eql(false)
  end
end