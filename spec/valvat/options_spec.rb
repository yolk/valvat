# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Options do
  describe '#[]' do
    it 'returns global config by default' do
      expect(described_class.new({})[:uk]).to be(false)
    end

    it 'returns option if set' do
      expect(described_class.new({ uk: {
                                   sandbox: true,
                                   client_id: '<client_id>',
                                   client_secret: '<client_secret>'
                                 } })[:uk]).to include(
                                   {
                                     sandbox: true,
                                     client_id: '<client_id>',
                                     client_secret: '<client_secret>'
                                   }
                                 )
    end

    context 'when options contains deprecated key requester_vat' do
      it 'returns it on new key' do
        expect(described_class.new({ requester_vat: 'DE123' }, silence: true)[:requester]).to be('DE123')
      end

      it 'prints deprecation warning' do
        expect do
          described_class.new({ requester_vat: 'DE123' })
        end.to output("DEPRECATED: The option :requester_vat is deprecated. Use :requester instead.\n").to_stdout
      end
    end

    context 'when options contains deprecated key savon' do
      it 'returns it on new key' do
        expect(described_class.new({ savon: { somekey: :somevalue } },
                                   silence: true)[:http]).to eq({ somekey: :somevalue })
      end

      it 'prints deprecation warning' do
        expect do
          described_class.new({ savon: { somekey: :somevalue } })
        end.to output("DEPRECATED: The option :savon is deprecated. Use :http instead.\n").to_stdout
      end
    end

    context 'when options contains deprecated key uk set to true' do
      it 'prints deprecation warning' do
        expect do
          described_class.new({ uk: true })
        end.to output(
          'DEPRECATED: The option :uk is not allowed to be set to `true` anymore. ' \
          "Instead it needs to be set to your HMRC API authentication credentials.\n"
        ).to_stdout
      end
    end
  end
end
