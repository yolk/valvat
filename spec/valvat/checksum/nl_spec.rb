require 'spec_helper'

describe Valvat::Checksum::NL do
  %w(NL123456782B12 NL802549391B01 NL808661863B01 NL820893559B01).each do |valid_vat|
    it "returns true on valid vat #{valid_vat}" do
      Valvat::Checksum.validate(valid_vat).should eql(true)
    end

    invalid_vat = "#{valid_vat[0..-5]}#{valid_vat[-2]}#{valid_vat[-3]}#{valid_vat[-4]}#{valid_vat[-1]}"

    it "returns false on invalid vat #{invalid_vat} #{valid_vat}" do
      Valvat::Checksum.validate(invalid_vat).should eql(false)
    end
  end
end