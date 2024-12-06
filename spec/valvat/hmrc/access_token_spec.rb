# frozen_string_literal: true

require 'spec_helper'

describe Valvat::HMRC::AccessToken do
  subject(:fetch_access_token) { described_class.fetch(Valvat::Options(options)) }

  let!(:options) { { uk: uk } }
  let(:uk) { { sandbox: true } }

  shared_examples 'return access token' do
    it 'return access token' do
      expect(fetch_access_token).to eq('<access_token>')
    end
  end

  shared_examples 'raises an error' do |error_message|
    it 'raises an error' do
      expect { fetch_access_token }.to raise_error(Valvat::HMRC::AccessToken::Error, error_message)
    end
  end

  context 'with valid data' do
    let(:uk) { super().merge(client_id: '<client_id>', client_secret: '<client_secret>') }
    let(:response) do
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

    before do
      stub_request(:post, 'https://test-api.service.hmrc.gov.uk/oauth/token')
        .with(
          body: {
            scope: described_class::SCOPE,
            grant_type: described_class::GRANT_TYPE,
            client_id: uk[:client_id],
            client_secret: uk[:client_secret]
          }
        )
        .to_return(response)
    end

    include_examples 'return access token'

    context 'when rate limit is exceeded' do
      let(:response) do
        {
          status: 301,
          headers: { location: 'https://test-api.service.hmrc.gov.uk/oauth/token' } # Redirection loop
        }
      end

      include_examples 'raises an error', 'Failed to fetch access token: rate limit exceeded'
    end
  end

  context 'with invalid data' do
    context 'when Client ID is empty' do
      let(:uk) { super().merge(client_id: nil, client_secret: '<client_secret>') }

      include_examples 'raises an error', 'Client ID is missing'
    end

    context 'when Client ID is missing' do
      let(:uk) { super().merge(client_secret: '<client_secret>') }

      include_examples 'raises an error', 'Client ID is missing'
    end

    context 'when Client secret is empty' do
      let(:uk) { super().merge(client_id: '<client_id>', client_secret: '') }

      include_examples 'raises an error', 'Client secret is missing'
    end

    context 'when Client secret is missing' do
      let(:uk) { super().merge(client_id: '<client_id>') }

      include_examples 'raises an error', 'Client secret is missing'
    end

    context 'when HMRC return error' do
      let(:uk) { super().merge(client_id: '<invlid_client_id>', client_secret: '<client_secret>') }
      let(:response) do
        {
          status: 401,
          body: {
            error: 'invalid_client',
            error_description: 'invalid client id or secret'
          }.to_json
        }
      end

      include_examples 'raises an error', 'Failed to fetch access token: invalid client id or secret'
    end
  end
end
