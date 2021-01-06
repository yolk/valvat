# frozen_string_literal: true

require 'spec_helper'

begin
  require "#{File.dirname(__FILE__)}/../../tmp/valid_vat_numbers.rb"
rescue LoadError
  VALID_VAT_NUMBERS = [].freeze
end

describe Valvat::Checksum do
  describe '#validate' do
    it 'returns true on VAT number with unknown checksum algorithm' do
      expect(described_class.validate('CZ699001237')).to be(true)
    end

    it 'returns false on corrupt number (e.g checks syntax)' do
      expect(described_class.validate('FI1234567891')).to be(false)
    end

    VALID_VAT_NUMBERS.each do |valid_vat|
      it "returns true on valid VAT number #{valid_vat}" do
        expect(described_class.validate(valid_vat)).to be(true)
      end
    end
  end
end
