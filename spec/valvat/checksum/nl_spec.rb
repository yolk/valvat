require 'spec_helper'

describe Valvat::Checksum::NL do
  %w(NL123456782B12 NL802549391B01 NL808661863B01 NL820893559B01 NL000099998B57 NL123456789B13).each do |valid_vat|
    it "returns true on valid vat #{valid_vat}" do
      expect(Valvat::Checksum.validate(valid_vat)).to eql(true)
    end

    invalid_vat = "#{valid_vat[0..-5]}#{valid_vat[-2]}#{valid_vat[-3]}#{valid_vat[-4]}#{valid_vat[-1]}#{valid_vat[-2]}#{valid_vat[-3]}"

    it "returns false on invalid vat #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to eql(false)
    end
  end
end