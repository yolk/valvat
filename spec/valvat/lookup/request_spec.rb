# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Lookup::Request do
  it 'returns Response on success' do
    response = described_class.new('IE6388047V', {}).perform
    expect(response).to be_a(Valvat::Lookup::Response)

    # Skip if VIES is down
    expect(response.to_hash[:name]).to eql('GOOGLE IRELAND LIMITED') unless response.is_a?(Valvat::Lookup::Fault)
  end

  it 'returns Fault on failure' do
    response = described_class.new('XC123123', {}).perform
    expect(response).to be_a(Valvat::Lookup::Fault)
    expect(response.to_hash).to eql({ valid: false })
  end

  context 'when Savon::UnknownOperationError is (wrongly) thrown' do
    before do
      dbl = double(Savon::Client)
      allow(Savon::Client).to receive(:new).and_return(dbl)
      allow(dbl).to receive(:call).and_raise(Savon::UnknownOperationError.new('from stub'))
    end

    it 'does handle it like vies down' do
      response = described_class.new('IE6388047V', {}).perform
      expect(response.to_hash[:error]).to be_a(Valvat::OperationUnknown)
    end
  end
end
