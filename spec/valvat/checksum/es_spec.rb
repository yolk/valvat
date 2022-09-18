# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Checksum::ES do
  %w[ESA13585625 ESB83871236 ESE54507058 ES25139013J ESQ1518001A ESQ5018001G ESX4942978W ESX7676464F ESB10317980
     ESY3860557K ESY2207765D ES28350472M ES41961720Z ESM1171170X ESK0928769Y].each do |valid_vat|
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

  describe 'some CIF categories (NPQRSW) require control-digit to be a letter' do
    invalid_vat = "ESP65474207"
    valid_vat = "ESP6547420G"

    it "returns false on invalid VAT #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
    end
    it "returns true on valid VAT #{valid_vat}" do
      expect(Valvat::Checksum.validate(valid_vat)).to be(true)
    end
  end

  describe 'some CIF categories (CDFGJNUV) allow both a numeric check digit and a letter' do
    %w[ESC65474207 ESC6547420G].each do |valid_vat|
      it "returns true on valid VAT #{valid_vat}" do
        expect(Valvat::Checksum.validate(valid_vat)).to be(true)
      end
    end
  end

  describe 'applies special rules to validation' do
    describe 'special NIF categories (KLM) require CD to be a letter and first two digits to be between 01 and 56 (inclusive)' do
      %w[ESK8201230M ESK0001230B].each do |invalid_vat|
        it "returns false on invalid VAT #{invalid_vat}" do
          expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
        end
      end
    end

    describe 'Arbitrarily invalid VATs' do
      %w[ESX0000000T ES00000001R ES00000000T ES99999999R].each do |invalid_vat|
        it "returns false on invalid VAT #{invalid_vat}" do
          expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
        end
      end
    end
  end

  describe 'if starts with [KLMXYZ\\d], is always a natural person' do
    invalid_vat = 'ESX65474207'
    it "returns false on invalid VAT #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
    end
  end

end
