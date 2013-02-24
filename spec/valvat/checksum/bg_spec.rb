require 'spec_helper'

describe Valvat::Checksum::BG do
  %w(BG123456786 BG926067143 BG926067770 BG0101011739 BG0121013021 BG0141018959).each do |valid_vat|
    it "returns true on valid vat #{valid_vat}" do
      Valvat::Checksum.validate(valid_vat).should eql(true)
    end

    invalid_vat = "#{valid_vat[0..-4]}#{valid_vat[-1]}#{valid_vat[-2]}#{valid_vat[-4]}"

    it "returns false on invalid vat #{invalid_vat}" do
      Valvat::Checksum.validate(invalid_vat).should eql(false)
    end
  end
end