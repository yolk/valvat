# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Checksum::CH do
  ['CHE-343.663.860', 'CHE343663860', 'CHE-355.036.078', 'CHE355036078', 'CHE-480.519.647',
   'CHE480519647'].each do |valid_vat|
    it "returns true on valid VAT #{valid_vat}" do
      expect(Valvat::Checksum.validate(valid_vat)).to be(true)
    end

    invalid_vat = "#{valid_vat[0..-4]}#{valid_vat[-1]}#{valid_vat[-2]}#{valid_vat[-3]}"

    it "returns false on invalid VAT #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
    end
  end
end
