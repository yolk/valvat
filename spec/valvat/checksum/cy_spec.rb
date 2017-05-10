require 'spec_helper'

describe Valvat::Checksum::CY do
  %w(CY01234567U CY00532445O).each do |valid_vat|
    it "returns true on valid vat #{valid_vat}" do
      expect(Valvat::Checksum.validate(valid_vat)).to be true
    end

    invalid_vat = "#{valid_vat[0..-4]}#{valid_vat[-2]}#{valid_vat[-3]}"

    it "returns false on invalid vat #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to be false
    end
  end
end
