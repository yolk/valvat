# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Options do
  describe '#[]' do
    it 'returns global config by default' do
      expect(described_class.new({})[:uk]).to include(
        {
          live: true,
          client_id: '<client_id>',
          client_secret: '<client_secret>'
        }
      )
    end

    it 'returns option if set' do
      expect(described_class.new({ uk: false })[:uk]).to be(false)
    end

    context 'when options contains deprecated key' do
      let(:options) { described_class.new({ requester_vat: 'DE123' }, silence: true) }

      it 'returns it on new key' do
        expect(options[:requester]).to be('DE123')
      end
    end
  end
end
