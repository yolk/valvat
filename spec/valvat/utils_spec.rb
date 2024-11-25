# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Utils do
  describe '#split' do
    it 'returns country and rest on VAT number as array' do
      expect(described_class.split('DE345889003')).to eql(%w[DE 345889003])
      expect(described_class.split('ESX4588900X')).to eql(%w[ES X4588900X])
    end

    it 'returns two nils on non-european iso codes as array' do
      expect(described_class.split('US345889003')).to eql([nil, nil])
      expect(described_class.split('RUX4588900X')).to eql([nil, nil])
    end

    it 'returns two nils on non-sense input as array' do
      expect(described_class.split('DE')).to eql([nil, nil])
      expect(described_class.split('X345889003')).to eql([nil, nil])
      expect(described_class.split('')).to eql([nil, nil])
      expect(described_class.split('1234')).to eql([nil, nil])
      expect(described_class.split(' ')).to eql([nil, nil]) # rubocop:disable Style/RedundantArgument
    end

    it 'returns EL (language iso code) on greek vat' do
      expect(described_class.split('EL999999999')).to eql(%w[EL 999999999])
    end

    it 'returns XI (vat number code) on northern ireland vat' do
      expect(described_class.split('XI999999999')).to eql(%w[XI 999999999])
    end
  end

  describe '#normalize' do
    it 'returns VAT number with upcase chars' do
      expect(described_class.normalize('de345889003')).to eql('DE345889003')
      expect(described_class.normalize('EsX4588900y')).to eql('ESX4588900Y')
    end

    it 'returns trimmed VAT number' do
      expect(described_class.normalize(' DE345889003')).to eql('DE345889003')
      expect(described_class.normalize('  DE345889003  ')).to eql('DE345889003')
      expect(described_class.normalize('DE345889003 ')).to eql('DE345889003')
    end

    it 'does not change already normalized VAT numbers' do
      expect(described_class.normalize('DE345889003')).to eql('DE345889003')
      expect(described_class.normalize('ESX4588900X')).to eql('ESX4588900X')
    end

    it 'removes spaces' do
      expect(described_class.normalize('DE 345889003')).to eql('DE345889003')
      expect(described_class.normalize('ESX  458 8900 X')).to eql('ESX4588900X')
    end

    it 'removes special chars' do
      expect(described_class.normalize('DE.345-889_00:3,;')).to eql('DE345889003')
      expect(described_class.normalize("→ DE·Ö34588 9003\0 ☺")).to eql(
        '→DEÖ345889003☺'
      )
    end
  end

  describe '#vat_country_to_iso_country' do
    it "returns iso country code on greek iso language 'EL'" do
      expect(described_class.vat_country_to_iso_country('EL')).to eql('GR')
    end

    it "returns iso country code on northern ireland vat prefix 'XI'" do
      expect(described_class.vat_country_to_iso_country('XI')).to eql('GB')
    end

    Valvat::Utils::EU_MEMBER_STATES.each do |iso|
      it "returns unchanged iso country code '#{iso}'" do
        expect(described_class.vat_country_to_iso_country(iso)).to eql(iso)
      end
    end
  end

  describe '#iso_country_to_vat_country' do
    it "returns VAT country EL on greek iso country code 'GR'" do
      expect(described_class.iso_country_to_vat_country('GR')).to eql('EL')
    end

    it "returns VAT country XI on british iso country code 'GB'" do
      expect(described_class.iso_country_to_vat_country('GB')).to eql('XI')
    end

    Valvat::Utils::EU_MEMBER_STATES.each do |c|
      next if c == 'GR'

      it "returns unchanged VAT country code '#{c}'" do
        expect(described_class.iso_country_to_vat_country(c)).to eql(c)
      end
    end
  end

  describe '#country_is_supported?' do
    Valvat::Utils::EU_MEMBER_STATES.each do |code|
      it "returns true on #{code}" do
        expect(described_class.country_is_supported?(code)).to be(true)
      end
    end

    it 'returns true on GB' do
      expect(described_class.country_is_supported?('GB')).to be(true)
    end

    %w[US AE CA CN BR AU NO ML].each do |code|
      it "returns false on #{code}" do
        expect(described_class.country_is_supported?(code)).to be(false)
      end
    end
  end

  describe '#deep_symbolize_keys' do
    it 'symbolizes keys of flat hash' do
      expect(described_class.deep_symbolize_keys({ 'a' => 1, :b => 2 })).to eql({ a: 1, b: 2 })
    end

    it 'symbolizes all hashes' do
      expect(described_class.deep_symbolize_keys({ 'a' => 1, :b => { 'c' => 3 } })).to eql({ a: 1, b: { c: 3 } })
    end
  end

  describe '#deep_merge' do
    let(:original_hash) { { a: 1, b: { c: 3 }, e: { w: 9 } } }
    let(:hash_to_merge) { { b: { d: 4 }, e: { w: 10 }, y: 11 } }

    it 'deep merge the nested hashes' do
      expect(described_class.deep_merge(original_hash, hash_to_merge)).to eql(
        {
          a: 1,
          b: {
            c: 3,
            d: 4
          },
          e: {
            w: 10
          },
          y: 11
        }
      )
    end
  end
end
