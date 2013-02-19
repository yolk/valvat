require 'spec_helper'

describe Valvat::Checksum::PL do
  %w(PL8567346215 PL5260211587 PL9720575348 PL5272650022).each do |valid_vat|
    it "returns true on valid vat #{valid_vat}" do
      Valvat::Checksum.validate(valid_vat).should eql(true)
    end

    invalid_vat = "#{valid_vat[0..-4]}#{valid_vat[-1]}#{valid_vat[-2]}#{valid_vat[-3]}"

    it "returns false on invalid vat #{invalid_vat}" do
      Valvat::Checksum.validate(invalid_vat).should eql(false)
    end
  end

  it "returns false on special case invalid vat PL8566445330" do
    Valvat::Checksum.validate("PL8566445330").should eql(false)
  end
end