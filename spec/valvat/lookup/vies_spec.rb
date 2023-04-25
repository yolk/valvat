# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Lookup::VIES do
  it 'returns hash with valid: true on success' do
    response = described_class.new('IE6388047V', {}).perform

    skip 'VIES is down' if Valvat::MemberStateUnavailable === response[:error]

    expect(response).to match({
                                valid: true,
                                address: '3RD FLOOR, GORDON HOUSE, BARROW STREET, DUBLIN 4',
                                country_code: 'IE',
                                vat_number: '6388047V',
                                name: 'GOOGLE IRELAND LIMITED',
                                request_date: kind_of(Date)
                              })
  end

  it 'returns hash with valid: false on invalid input' do
    response = described_class.new('XC123123', {}).perform
    expect(response.to_hash).to match({ valid: false, faultstring: 'INVALID_INPUT', faultcode: 'env:Server' })
  end
end
