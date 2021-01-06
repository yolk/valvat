# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Checksum::NL do
  %w[NL123456782B12 NL802549391B01 NL808661863B01 NL820893559B01 NL000099998B57 NL123456789B13].each do |valid|
    it "returns true on valid VAT #{valid}" do
      expect(Valvat::Checksum.validate(valid)).to be(true)
    end

    invalid = "#{valid[0..-5]}#{valid[-2]}#{valid[-3]}#{valid[-4]}#{valid[-1]}#{valid[-2]}#{valid[-3]}"

    it "returns false on invalid VAT #{invalid}" do
      expect(Valvat::Checksum.validate(invalid)).to be(false)
    end
  end
end
