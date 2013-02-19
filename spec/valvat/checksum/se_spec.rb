require 'spec_helper'

describe Valvat::Checksum::SE do
  %w(SE136695975523 SE556464687401 SE502052817901 SE556555952201 SE556084097601).each do |valid_vat|
    it "returns true on valid vat #{valid_vat}" do
      Valvat::Checksum.validate(valid_vat).should eql(true)
    end

    invalid_vat = "#{valid_vat[0..-4]}#{valid_vat[-1]}#{valid_vat[-2]}#{valid_vat[-3]}"

    it "returns false on invalid vat #{invalid_vat}" do
      Valvat::Checksum.validate(invalid_vat).should eql(false)
    end
  end

  it "returns false on special case invalid vat SE556464687400" do
    Valvat::Checksum.validate("SE556464687400").should eql(false)
  end
end