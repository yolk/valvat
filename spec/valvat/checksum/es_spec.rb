# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Checksum::ES do
  %w[ESA13585625 ESB83871236 ESE54507058 ES25139013J ESQ1518001A ESQ5018001G ESX4942978W ESX7676464F ESB10317980
     ESY3860557K ESY2207765D].each do |valid_vat|
    it "returns true on valid VAT #{valid_vat}" do
      expect(Valvat::Checksum.validate(valid_vat)).to be(true)
    end

    invalid_vat = "#{valid_vat[0..-6]}#{valid_vat[-2]}#{valid_vat[-5]}#{valid_vat[-4]}#{valid_vat[-3]}#{valid_vat[-1]}"

    it "returns false on invalid VAT #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
    end
  end

  describe 'if starts with [KLMXYZ\\d], is always a natural person' do
    invalid_vat = 'ESX65474207'
    it "returns false on invalid VAT #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
    end
  end
end
