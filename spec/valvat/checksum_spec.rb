# frozen_string_literal: true

require 'spec_helper'

begin
  require "#{File.dirname(__FILE__)}/../../tmp/valid_vat_numbers.rb"
rescue LoadError
  VALID_VAT_NUMBERS = [].freeze
end

# Syntax is correct, but checksum invalid
INVALID_VAT_NUMBERS = %w[
  DE002768611 DE161216774 DE192970834 DE223361232 DE226095231
  DE227411313 DE230928917 DE232123248 DE267748405 DE275615509
  DE311927825 DE329214395 DE815842425 DE821530465 DE999999999
].freeze

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

    INVALID_VAT_NUMBERS.each do |invalid_vat|
      it "returns false on invalid VAT number #{invalid_vat}" do
        expect(described_class.validate(invalid_vat)).to be(false)
      end
    end
  end
end
