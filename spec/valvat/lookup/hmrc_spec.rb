# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Lookup::HMRC do
  subject(:lookup) { described_class.new("GB#{vat_number}", options).perform }

  let(:options) { { uk: uk } }
  let(:uk) { { sandbox: true, client_id: '<client_id>', client_secret: '<client_secret>' } }
  let(:vat_number) { '553557881' }
  let(:authentication_response) do
    {
      status: 200,
      body: {
        access_token: '<access_token>',
        token_type: 'bearer',
        expires_in: 14_400,
        scope: 'read:vat'
      }.to_json
    }
  end
  let(:lookup_response) do
    {
      status: 200,
      body: {
        target: {
          address: {
            line1: '131B Barton Hamlet',
            postcode: 'SW97 5CK',
            countryCode: 'GB'
          },
          vatNumber: vat_number,
          name: 'Credite Sberger Donal Inc.'
        },
        processingDate: '2024-11-19T15:11:52+00:00'
      }.to_json
    }
  end

  shared_examples 'returns hash with valid: true and formatted data on success' do
    it 'returns hash with valid: true and formatted data on success' do
      expect(lookup).to include(
        valid: true,
        address: "131B Barton Hamlet\nSW97 5CK\nGB",
        country_code: 'GB',
        vat_number: vat_number,
        name: 'Credite Sberger Donal Inc.',
        request_date: kind_of(Time)
      )
    end
  end

  shared_examples 'returns hash with valid: false' do
    it 'returns hash with valid: false' do
      expect(lookup).to include(valid: false)
    end
  end

  before do
    Valvat.configure(uk: uk)

    stub_request(:post, 'https://test-api.service.hmrc.gov.uk/oauth/token')
      .with(
        body: {
          scope: Valvat::HMRC::AccessToken::SCOPE,
          grant_type: Valvat::HMRC::AccessToken::GRANT_TYPE,
          client_id: uk[:client_id],
          client_secret: uk[:client_secret]
        }
      )
      .to_return(authentication_response)

    stub_request(:get, "https://test-api.service.hmrc.gov.uk/organisations/vat/check-vat-number/lookup/#{vat_number}")
      .with(
        headers: {
          'Accept' => 'application/vnd.hmrc.2.0+json',
          'Authorization' => 'Bearer <access_token>'
        }
      )
      .to_return(lookup_response)
  end

  after do
    Valvat.configure(uk: false)
  end

  context 'with valid data' do
    let(:vat_number) { '553557881' }

    include_examples 'returns hash with valid: true and formatted data on success'

    context 'when :uk option is not set' do
      let(:options) { {} }

      include_examples 'returns hash with valid: true and formatted data on success'
    end

    context 'when options are not set' do
      let(:options) { nil }

      include_examples 'returns hash with valid: true and formatted data on success'

      context 'when option uk: false set globally' do
        before { Valvat.configure(uk: false) }

        include_examples 'returns hash with valid: false'
      end

      context 'when option uk: nil set globally' do
        before { Valvat.configure(uk: nil) }

        include_examples 'returns hash with valid: false'
      end
    end

    context 'when overwrite global :uk setting' do
      let(:options) { { uk: false } }

      before { Valvat.configure(uk: uk) }

      include_examples 'returns hash with valid: false'
    end
  end

  context 'with invalid data' do
    shared_examples 'returns error' do
      it 'returns error' do
        expect { lookup }.not_to raise_error
        expect(lookup[:error]).to be_a(Valvat::HMRC::AccessToken::Error)
        expect(lookup[:valid]).to be_nil
      end
    end

    context 'when VAT invalid' do
      let(:vat_number) { '123456789' }
      let(:lookup_response) do
        {
          status: 404,
          body: {
            code: 'NOT_FOUND',
            message: 'targetVrn does not match a registered company'
          }.to_json
        }
      end

      include_examples 'returns hash with valid: false'
    end

    context 'when missing Authentication credentials (the default)' do
      let(:uk) { super().merge(client_id: nil, client_secret: nil) }

      include_examples 'returns error'
    end

    context 'when Authentication failed' do
      let(:uk) { super().merge(client_id: '<invlid_client_id>') }
      let(:authentication_response) do
        {
          status: 401,
          body: {
            error: 'invalid_client',
            error_description: 'invalid client id or secret'
          }.to_json
        }
      end

      include_examples 'returns error'
    end
  end
end
