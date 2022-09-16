# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Lookup::Vies do
  before do
    WebMock.allow_net_connect!
  end

  it 'returns valid: true on success' do
    response = described_class.new('IE6388047V', {}).perform

    expect(response[:valid]).to eql(true)
    expect(response[:name]).to eql('GOOGLE IRELAND LIMITED')
  end

  it 'returns valid: false on invalid input' do
    response = described_class.new('XC123123', {}).perform
    expect(response.to_hash).to eql({ valid: false, faultstring: 'INVALID_INPUT', faultcode: 'env:Server' })
  end
end
