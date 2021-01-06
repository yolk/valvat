# frozen_string_literal: true

require 'spec_helper'

describe Valvat do
  describe '#new' do
    it 'demands one and only one argument' do
      expect { described_class.new }.to raise_error(ArgumentError)
      expect { described_class.new('a', 'b') }.to raise_error(ArgumentError)
      expect { described_class.new('a') }.not_to raise_error
    end

    it 'normalizes input string' do
      expect(described_class.new('de25.9597,69 7').to_s).to eql('DE259597697')
      expect(described_class.new('de25.9597,69 7').iso_country_code).to eql('DE')
    end
  end

  describe 'Valvat()' do
    it 'initializes new Valvat instance on string' do
      expect(Valvat('abc')).to be_kind_of(described_class)
    end

    it 'returns same Valvat instance on Valvat instance' do
      vat = described_class.new('abc')
      expect(Valvat(vat)).to be_kind_of(described_class)
      expect(Valvat(vat).object_id).to eql(vat.object_id)
    end
  end

  describe '#blank?' do
    it 'returns true when when initialized with nil' do
      expect(described_class.new(nil)).to be_blank
    end

    it 'returns true when when initialized with an empty string' do
      expect(described_class.new(' ')).to be_blank
    end

    it 'returns false when initialized with a value' do
      expect(described_class.new('DE259597697')).not_to be_blank
    end
  end

  context 'with european VAT number' do
    let(:de_vat) { described_class.new('DE259597697') } # valid & exists
    let(:invalid_checksum) { described_class.new('DE259597687') } # valid & invalid checksum
    let(:at_vat) { described_class.new('ATU458890031') } # invalid
    let(:gr_vat) { described_class.new('EL999943280') } # valid & exists

    describe '#valid?' do
      it 'returns true on valid numbers' do
        expect(de_vat).to be_valid
        expect(gr_vat).to be_valid
      end

      it 'returns false on invalid numbers' do
        expect(at_vat).not_to be_valid
      end
    end

    describe '#valid_checksum?' do
      it 'returns true on valid numbers' do
        expect(de_vat).to be_valid_checksum
        expect(gr_vat).to be_valid_checksum
      end

      it 'returns false on invalid numbers' do
        expect(at_vat).not_to be_valid_checksum
        expect(invalid_checksum).not_to be_valid_checksum
      end
    end

    describe '#exist(s)?' do
      it 'returns true with existing VAT numbers' do
        allow(Valvat::Lookup).to receive_messages(validate: true)
        expect(de_vat.exists?).to be(true)
        expect(gr_vat.exists?).to be(true)
        expect(de_vat.exist?).to be(true)
        expect(gr_vat.exist?).to be(true)
      end

      it 'returns false with not existing VAT numbers' do
        allow(Valvat::Lookup).to receive_messages(validate: false)
        expect(at_vat.exists?).to be(false)
        expect(at_vat.exist?).to be(false)
      end

      it 'calls Valvat::Lookup.validate with options' do
        allow(Valvat::Lookup).to receive_messages(validate: true)
        expect(de_vat.exists?(detail: true, bla: 'blupp')).to be(true)
        expect(Valvat::Lookup).to have_received(:validate).once.with(
          de_vat, detail: true, bla: 'blupp'
        )
      end
    end

    describe '#iso_country_code' do
      it 'returns iso country code on iso_country_code' do
        expect(de_vat.iso_country_code).to eql('DE')
        expect(at_vat.iso_country_code).to eql('AT')
      end

      it 'returns GR iso country code on greek VAT number' do
        expect(gr_vat.iso_country_code).to eql('GR')
      end
    end

    describe '#vat_country_code' do
      it 'returns iso country code on iso_country_code' do
        expect(de_vat.vat_country_code).to eql('DE')
        expect(at_vat.vat_country_code).to eql('AT')
      end

      it 'returns EL iso language code on greek VAT number' do
        expect(gr_vat.vat_country_code).to eql('EL')
      end
    end

    describe '#european?' do
      it 'returns true' do
        expect(de_vat).to be_european
        expect(at_vat).to be_european
        expect(gr_vat).to be_european
      end
    end

    describe '#to_s' do
      it 'returns full VAT number' do
        expect(de_vat.to_s).to eql('DE259597697')
        expect(at_vat.to_s).to eql('ATU458890031')
        expect(gr_vat.to_s).to eql('EL999943280')
      end
    end

    describe '#inspect' do
      it 'returns VAT number with iso country code' do
        expect(de_vat.inspect).to eql('#<Valvat DE259597697 DE>')
        expect(at_vat.inspect).to eql('#<Valvat ATU458890031 AT>')
        expect(gr_vat.inspect).to eql('#<Valvat EL999943280 GR>')
      end
    end

    describe '#to_a' do
      it 'calls Valvat::Utils.split with raw VAT number and returns result' do
        allow(Valvat::Utils).to receive(:split).and_return(%w[a b])
        de_vat # initialize
        expect(Valvat::Utils).to have_received(:split).once.with('DE259597697')
        expect(de_vat.to_a).to eql(%w[a b])
      end
    end
  end

  context 'with VAT number from outside of europe' do
    let(:us_vat) { described_class.new('US345889003') }
    let(:ch_vat) { described_class.new('CH445889003') }

    describe '#valid?' do
      it 'returns false' do
        expect(us_vat).not_to be_valid
        expect(ch_vat).not_to be_valid
      end
    end

    describe '#exist?' do
      it 'returns false' do
        expect(us_vat).not_to be_exist
        expect(ch_vat).not_to be_exist
      end
    end

    describe '#iso_country_code' do
      it 'returns nil' do
        expect(us_vat.iso_country_code).to be(nil)
        expect(ch_vat.iso_country_code).to be(nil)
      end
    end

    describe '#vat_country_code' do
      it 'returns nil' do
        expect(us_vat.vat_country_code).to be(nil)
        expect(ch_vat.vat_country_code).to be(nil)
      end
    end

    describe '#european?' do
      it 'returns false' do
        expect(us_vat).not_to be_european
        expect(ch_vat).not_to be_european
      end
    end

    describe '#to_s' do
      it 'returns full given VAT number' do
        expect(us_vat.to_s).to eql('US345889003')
        expect(ch_vat.to_s).to eql('CH445889003')
      end
    end

    describe '#inspect' do
      it 'returns VAT number without iso country code' do
        expect(us_vat.inspect).to eql('#<Valvat US345889003>')
        expect(ch_vat.inspect).to eql('#<Valvat CH445889003>')
      end
    end
  end

  context 'with non-sense/empty VAT number' do
    let(:only_iso_vat) { described_class.new('DE') }
    let(:num_vat) { described_class.new('12445889003') }
    let(:empty_vat) { described_class.new('') }
    let(:nil_vat) { described_class.new('') }

    describe '#valid?' do
      it 'returns false' do
        expect(only_iso_vat).not_to be_valid
        expect(num_vat).not_to be_valid
        expect(empty_vat).not_to be_valid
        expect(nil_vat).not_to be_valid
      end
    end

    describe '#exist?' do
      it 'returns false' do
        expect(only_iso_vat).not_to be_exist
        expect(num_vat).not_to be_exist
        expect(empty_vat).not_to be_exist
        expect(nil_vat).not_to be_exist
      end
    end

    describe '#iso_country_code' do
      it 'returns nil' do
        expect(only_iso_vat.iso_country_code).to be(nil)
        expect(num_vat.iso_country_code).to be(nil)
        expect(empty_vat.iso_country_code).to be(nil)
        expect(nil_vat.iso_country_code).to be(nil)
      end
    end

    describe '#vat_country_code' do
      it 'returns nil' do
        expect(only_iso_vat.vat_country_code).to be(nil)
        expect(num_vat.vat_country_code).to be(nil)
        expect(empty_vat.vat_country_code).to be(nil)
        expect(nil_vat.vat_country_code).to be(nil)
      end
    end

    describe '#european?' do
      it 'returns false' do
        expect(only_iso_vat).not_to be_european
        expect(num_vat).not_to be_european
        expect(empty_vat).not_to be_european
        expect(nil_vat).not_to be_european
      end
    end

    describe '#to_s' do
      it 'returns full given VAT number' do
        expect(only_iso_vat.to_s).to eql('DE')
        expect(num_vat.to_s).to eql('12445889003')
        expect(empty_vat.to_s).to eql('')
        expect(nil_vat.to_s).to eql('')
      end
    end

    describe '#inspect' do
      it 'returns VAT number without iso country code' do
        expect(only_iso_vat.inspect).to eql('#<Valvat DE>')
        expect(num_vat.inspect).to eql('#<Valvat 12445889003>')
        expect(empty_vat.inspect).to eql('#<Valvat >')
        expect(nil_vat.inspect).to eql('#<Valvat >')
      end
    end
  end
end
