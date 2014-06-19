require 'spec_helper'

describe Valvat::Checksum::IT do
  %w(IT12345670785 IT01897810162 IT00197200132 IT02762750210).each do |valid_vat|
    it "returns true on valid vat #{valid_vat}" do
      expect(Valvat::Checksum.validate(valid_vat)).to eql(true)
    end

    invalid_vat = "#{valid_vat[0..-3]}#{valid_vat[-1]}#{valid_vat[-2]}"

    it "returns false on invalid vat #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to eql(false)
    end
  end

  it "returns false on invalid special case vat IT12345671783" do
    expect(Valvat::Checksum.validate("IT12345671783")).to eql(false)
  end

  it "returns false on invalid special case vat IT00000000133" do
    expect(Valvat::Checksum.validate("IT00000000133")).to eql(false)
  end
end