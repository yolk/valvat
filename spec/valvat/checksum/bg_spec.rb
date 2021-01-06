# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Checksum::BG do
  %w[BG123456786 BG926067143 BG926067770 BG0101011739 BG0121013021 BG5041019992 BG1521687837
     BG1431889037].each do |valid_vat|
    it "returns true on valid VAT #{valid_vat}" do
      expect(Valvat::Checksum.validate(valid_vat)).to be(true)
    end

    invalid_vat = "#{valid_vat[0..-4]}#{valid_vat[-1]}#{valid_vat[-2]}#{valid_vat[-4]}"

    it "returns false on invalid VAT #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
    end
  end
end
