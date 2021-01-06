# frozen_string_literal: true

require 'spec_helper'

if defined?(ActiveModel)
  class Invoice < ModelBase
    validates :vat_number, valvat: true
  end

  class InvoiceWithLookup < ModelBase
    validates :vat_number, valvat: { lookup: true }
  end

  class InvoiceWithLookupAndFailIfDown < ModelBase
    validates :vat_number, valvat: { lookup: :fail_if_down }
  end

  class InvoiceAllowBlank < ModelBase
    validates :vat_number, valvat: { allow_blank: true }
  end

  class InvoiceAllowBlankOnAll < ModelBase
    validates :vat_number, valvat: true, allow_blank: true
  end

  class InvoiceCheckCountry < ModelBase
    validates :vat_number, valvat: { match_country: :country }

    def country
      @attributes[:country]
    end
  end

  class InvoiceCheckCountryWithLookup < ModelBase
    validates :vat_number, valvat: { match_country: :country, lookup: true }

    def country
      @attributes[:country]
    end
  end

  class InvoiceWithChecksum < ModelBase
    validates :vat_number, valvat: { checksum: true }
  end

  describe Invoice do
    before do
      I18n.locale = :en
    end

    context 'with valid VAT number' do
      it 'is valid' do
        expect(described_class.new(vat_number: 'DE259597697')).to be_valid
      end
    end

    context 'with invalid VAT number' do
      let(:invoice) { described_class.new(vat_number: 'DE259597697123') }

      it 'is not valid' do
        expect(invoice).not_to be_valid
      end

      it 'adds default (country specific) error message' do
        invoice.valid?
        expect(invoice.errors[:vat_number]).to eql(['is not a valid German VAT number'])
      end

      context 'with DE locale' do
        before do
          I18n.locale = :de
        end

        it 'adds translated error message' do
          invoice.valid?
          expect(invoice.errors[:vat_number]).to eql(['ist keine gültige deutsche USt-IdNr.'])
        end
      end

      context 'with PT locale' do
        before do
          I18n.locale = :pt
        end

        it 'adds translated error message' do
          invoice.valid?
          expect(invoice.errors[:vat_number]).to eql(['O NIF alemão não é válido.'])
        end
      end

      context 'with i18n translation in place' do
        before do
          I18n.backend.store_translations(:en, activemodel: {
                                            errors: { models: { invoice: { invalid_vat: 'is ugly.' } } }
                                          })
        end

        after { I18n.reload! }

        it 'uses translation' do
          invoice.valid?
          expect(invoice.errors[:vat_number]).to eql(['is ugly.'])
        end
      end

      context 'with i18n translation with country_adjective placeholder in place' do
        before do
          msg = 'is not a %{country_adjective} vat' # rubocop:disable Style/FormatStringToken
          translation = { activemodel: { errors: { models: { invoice: { invalid_vat: msg } } } } }
          I18n.backend.store_translations(:en, translation)
        end

        after { I18n.reload! }

        it 'replaces country_adjective placeholder' do
          invoice = described_class.new(vat_number: 'IE123')
          invoice.valid?
          expect(invoice.errors[:vat_number]).to eql(['is not a Irish vat'])
        end

        it "falls back to 'European' if country is missing" do
          invoice = described_class.new(vat_number: 'XX123')
          invoice.valid?
          expect(invoice.errors[:vat_number]).to eql(['is not a European vat'])
        end
      end
    end

    context 'with blank VAT number' do
      it 'is not valid' do
        expect(described_class.new(vat_number: '')).not_to be_valid
        expect(described_class.new(vat_number: nil)).not_to be_valid
      end
    end
  end

  describe InvoiceWithLookup do
    context 'with valid but not existing VAT number' do
      before do
        allow(Valvat::Syntax).to receive_messages(validate: true)
        allow(Valvat::Lookup).to receive_messages(validate: false)
      end

      it 'is not valid' do
        expect(described_class.new(vat_number: 'DE123')).not_to be_valid
      end
    end

    context 'with valid and existing VAT number' do
      before do
        allow(Valvat::Syntax).to receive_messages(validate: true)
        allow(Valvat::Lookup).to receive_messages(validate: true)
      end

      it 'is valid' do
        expect(described_class.new(vat_number: 'DE123')).to be_valid
      end
    end

    context 'with valid VAT number and VIES country service down' do
      before do
        allow(Valvat::Syntax).to receive_messages(validate: true)
        allow(Valvat::Lookup).to receive_messages(validate: nil)
      end

      it 'is valid' do
        expect(described_class.new(vat_number: 'DE123')).to be_valid
      end
    end
  end

  describe InvoiceWithLookupAndFailIfDown do
    let(:record) { described_class.new }

    context 'with valid VAT number and VIES country service down' do
      before do
        allow(Valvat::Syntax).to receive_messages(validate: true)
        allow(Valvat::Lookup).to receive_messages(validate: nil)
      end

      it 'is not valid' do
        expect(record).not_to be_valid
        msg = 'Unable to validate your VAT number: the VIES service is down. Please try again later.'
        expect(record.errors[:vat_number]).to eql([msg])
      end
    end
  end

  describe InvoiceAllowBlank do
    context 'with blank VAT number' do
      it 'is valid' do
        expect(described_class.new(vat_number: '')).to be_valid
        expect(described_class.new(vat_number: nil)).to be_valid
      end
    end
  end

  describe InvoiceAllowBlankOnAll do
    context 'with blank VAT number' do
      it 'is valid' do
        expect(described_class.new(vat_number: '')).to be_valid
        expect(described_class.new(vat_number: nil)).to be_valid
      end
    end
  end

  describe InvoiceCheckCountry do
    it 'is not valid on blank country' do
      expect(described_class.new(country: nil, vat_number: 'DE259597697')).not_to be_valid
      expect(described_class.new(country: '', vat_number: 'DE259597697')).not_to be_valid
    end

    it 'is not valid on wired country' do
      expect(described_class.new(country: 'XAXXX', vat_number: 'DE259597697')).not_to be_valid
      expect(described_class.new(country: 'ZO', vat_number: 'DE259597697')).not_to be_valid
    end

    it 'is not valid on mismatching (eu) country' do
      expect(described_class.new(country: 'FR', vat_number: 'DE259597697')).not_to be_valid
      expect(described_class.new(country: 'AT', vat_number: 'DE259597697')).not_to be_valid
      expect(described_class.new(country: 'DE', vat_number: 'ATU65931334')).not_to be_valid
    end

    it 'is valid on matching country' do
      expect(described_class.new(country: 'DE', vat_number: 'DE259597697')).to be_valid
      expect(described_class.new(country: 'AT', vat_number: 'ATU65931334')).to be_valid
    end

    it 'gives back error message with country from :country_match' do
      invoice = described_class.new(country: 'FR', vat_number: 'DE259597697')
      invoice.valid?
      expect(invoice.errors[:vat_number]).to eql(['is not a valid French VAT number'])
    end

    it 'gives back error message with country from :country_match even on invalid VAT number' do
      invoice = described_class.new(country: 'FR', vat_number: 'DE259597697123')
      invoice.valid?
      expect(invoice.errors[:vat_number]).to eql(['is not a valid French VAT number'])
    end
  end

  describe InvoiceCheckCountryWithLookup do
    before do
      allow(Valvat::Syntax).to receive_messages(validate: true)
      allow(Valvat::Lookup).to receive_messages(validate: true)
    end

    it 'avoids lookup or syntax check on failed because of mismatching country' do
      described_class.new(country: 'FR', vat_number: 'DE259597697').valid?
      expect(Valvat::Syntax).not_to have_received(:validate)
      expect(Valvat::Lookup).not_to have_received(:validate)
    end

    it 'check syntax and looup on matching country' do
      described_class.new(country: 'DE', vat_number: 'DE259597697').valid?
      expect(Valvat::Syntax).to have_received(:validate)
      expect(Valvat::Lookup).to have_received(:validate)
    end
  end

  describe InvoiceWithChecksum do
    context 'with valid VAT number' do
      it 'is valid' do
        expect(described_class.new(vat_number: 'DE259597697')).to be_valid
      end
    end

    context 'with invalid VAT number' do
      it 'is not valid' do
        expect(described_class.new(vat_number: 'DE259597687')).not_to be_valid
      end
    end
  end
end
