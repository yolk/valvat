# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Lookup::HMRC do
  before do
    stub_const('Valvat::Lookup::HMRC::ENDPOINT_URL', 'https://test-api.service.hmrc.gov.uk/organisations/vat/check-vat-number/lookup')
  end

  it 'returns hash with valid: true on success' do
    response = described_class.new('GB553557881', { uk: true }).perform

    expect(response).to match({
                                valid: true,
                                address: "131B Barton Hamlet\nSW97 5CK\nGB",
                                country_code: 'GB',
                                vat_number: '553557881',
                                name: 'Credite Sberger Donal Inc.',
                                request_date: kind_of(Time)
                              })
  end

  it 'returns hash with valid: false on invalid input' do
    response = described_class.new('GB123456789', { uk: true }).perform
    expect(response).to match({ valid: false })
  end

  it 'returns hash with valid: false on valid input with :uk option not set' do
    response = described_class.new('GB553557881', {}).perform
    expect(response).to match({ valid: false })
  end
end
