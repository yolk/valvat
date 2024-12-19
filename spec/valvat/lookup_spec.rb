# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Lookup do
  shared_context 'with hmrc configuration' do
    let(:uk) { { sandbox: true, client_id: '<client_id>', client_secret: '<client_secret>' } }
    let(:vat_number) { nil }
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
    let(:lookup_request_url) { "https://test-api.service.hmrc.gov.uk/organisations/vat/check-vat-number/lookup/#{vat_number}" }
    let(:lookup_response) do
      {
        status: 200,
        body: {
          target: {
            address: {
              line1: '1 PRINCIPAL PLACE',
              line2: 'WORSHIP STREET',
              line3: 'LONDON',
              postcode: 'EC2A 2FA',
              countryCode: 'GB'
            },
            vatNumber: vat_number,
            name: 'AMAZON EU SARL'
          },
          processingDate: '2024-11-19T15:11:52+00:00'
        }.to_json
      }
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

      stub_request(:get, lookup_request_url)
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
  end

  describe '#validate' do
    context 'with existing EU VAT number' do
      it 'returns true' do
        result = described_class.validate('IE6388047V')
        skip 'VIES is down' if result.nil?
        expect(result).to be(true)
      end

      it 'allows Valvat instance as input' do
        result = described_class.validate(Valvat.new('IE6388047V'))
        skip 'VIES is down' if result.nil?
        expect(result).to be(true)
      end

      context 'with details' do
        it 'returns hash of details instead of true' do
          result = described_class.validate('IE6388047V', detail: true)
          skip 'VIES is down' if result.nil?

          expect(result).to match({
                                    request_date: kind_of(Date),
                                    country_code: 'IE',
                                    vat_number: '6388047V',
                                    name: 'GOOGLE IRELAND LIMITED',
                                    address: '3RD FLOOR, GORDON HOUSE, BARROW STREET, DUBLIN 4',
                                    valid: true
                                  })
        end
      end
    end

    context 'with existing GB VAT number' do
      include_context 'with hmrc configuration'

      let!(:vat_number) { '727255821' }

      it 'returns true' do
        result = described_class.validate("GB#{vat_number}")
        expect(result).to be(true)
      end

      it 'returns details in format similar to VIES' do
        result = described_class.validate("GB#{vat_number}", detail: true)
        expect(result).to match({
                                  request_date: kind_of(Time),
                                  country_code: 'GB',
                                  vat_number: vat_number,
                                  name: 'AMAZON EU SARL',
                                  address: "1 PRINCIPAL PLACE\nWORSHIP STREET\nLONDON\nEC2A 2FA\nGB",
                                  valid: true
                                })
      end
    end

    context 'with not existing EU VAT number' do
      it 'returns false' do
        result =  described_class.validate('IE6388048V')
        skip 'VIES is down' if result.nil?
        expect(result).to be(false)
      end

      context 'with details' do
        it 'still returns false' do
          result = described_class.validate('LU21416128', detail: true)
          skip 'VIES is down' if result.nil?
          expect(result).to be(false)
        end
      end
    end

    context 'with not existing GB VAT number' do
      include_context 'with hmrc configuration'

      let(:vat_number) { '727255820' }
      let(:lookup_response) do
        {
          status: 404,
          body: {
            code: 'NOT_FOUND',
            message: 'targetVrn does not match a registered company'
          }.to_json
        }
      end

      it 'returns false' do
        result =  described_class.validate("GB#{vat_number}")
        expect(result).to be(false)
      end
    end

    context 'with invalid country code / input' do
      it 'returns false' do
        expect(described_class.validate('AE259597697')).to be(false)
        expect(described_class.validate('')).to be(false)
      end
    end

    context 'with request identifier' do
      it 'returns hash of details instead of true' do
        result = described_class.validate('IE6388047V', requester: 'DE129415943')

        skip 'VIES is down' if result.nil?

        expect(result).to match({
                                  request_date: kind_of(Date),
                                  request_identifier: /\A[\w\W]{16}\Z/,
                                  country_code: 'IE',
                                  vat_number: '6388047V',
                                  name: 'GOOGLE IRELAND LIMITED',
                                  company_type: nil,
                                  address: '3RD FLOOR, GORDON HOUSE, BARROW STREET, DUBLIN 4',
                                  valid: true
                                })
      end

      context 'with GB VAT number' do
        include_context 'with hmrc configuration'

        let(:vat_number) { '727255821' }
        let(:lookup_request_url) { "https://test-api.service.hmrc.gov.uk/organisations/vat/check-vat-number/lookup/#{vat_number}/#{vat_number}" }
        let(:lookup_response) do
          {
            status: 200,
            body: {
              target: {
                address: {
                  line1: '1 PRINCIPAL PLACE',
                  line2: 'WORSHIP STREET',
                  line3: 'LONDON',
                  postcode: 'EC2A 2FA',
                  countryCode: 'GB'
                },
                vatNumber: vat_number,
                name: 'AMAZON EU SARL'
              },
              requester: vat_number,
              consultationNumber: 'RLH-RFQ-AFW',
              processingDate: '2024-11-19T15:11:52+00:00'
            }.to_json
          }
        end

        it 'returns hash of details with request number' do
          response = described_class.validate("GB#{vat_number}", requester: "GB#{vat_number}")
          expect(response).to include(
            request_date: kind_of(Time),
            request_identifier: 'RLH-RFQ-AFW',
            country_code: 'GB',
            vat_number: vat_number,
            name: 'AMAZON EU SARL',
            address: "1 PRINCIPAL PLACE\nWORSHIP STREET\nLONDON\nEC2A 2FA\nGB",
            valid: true
          )
        end

        context 'when requester is not from GB' do # rubocop: disable RSpec/NestedGroups
          let(:lookup_request_url) { "https://test-api.service.hmrc.gov.uk/organisations/vat/check-vat-number/lookup/#{vat_number}/6388047V" }
          let(:lookup_response) do
            {
              status: 422,
              body: {
                code: 'INVALID_REQUEST',
                message: 'Invalid requesterVrn - Vrn parameters should be 9 or 12 digits'
              }.to_json
            }
          end

          it 'raises exception' do
            expect do
              described_class.validate("GB#{vat_number}", requester: 'IE6388047V')
            end.to raise_error(Valvat::InvalidRequester,
                               'The HMRC web service returned the error: ' \
                               'INVALID_REQUEST (Invalid requesterVrn - Vrn parameters should be 9 or 12 digits)')
          end
        end

        context 'when requester is not valid' do # rubocop: disable RSpec/NestedGroups
          let(:lookup_request_url) { "https://test-api.service.hmrc.gov.uk/organisations/vat/check-vat-number/lookup/#{vat_number}/6388047" }
          let(:lookup_response) do
            {
              status: 422,
              body: {
                code: 'INVALID_REQUEST',
                message: 'Invalid requesterVrn - Vrn parameters should be 9 or 12 digits'
              }.to_json
            }
          end

          it 'raises exception' do
            expect do
              described_class.validate("GB#{vat_number}", requester: 'GB6388047')
            end.to raise_error(Valvat::InvalidRequester,
                               'The HMRC web service returned the error: ' \
                               'INVALID_REQUEST (Invalid requesterVrn - Vrn parameters should be 9 or 12 digits)')
          end
        end
      end

      context 'when set in global config' do
        before { Valvat.configure(requester: 'IE6388047V') }
        after { Valvat.configure(requester: nil) }

        it 'returns hash of details instead of true' do
          result = described_class.validate('IE6388047V')

          skip 'VIES is down' if result.nil?

          expect(result).to match({
                                    request_date: kind_of(Date),
                                    request_identifier: /\A[\w\W]{16}\Z/,
                                    country_code: 'IE',
                                    vat_number: '6388047V',
                                    name: 'GOOGLE IRELAND LIMITED',
                                    company_type: nil,
                                    address: '3RD FLOOR, GORDON HOUSE, BARROW STREET, DUBLIN 4',
                                    valid: true
                                  })
        end
      end
    end
  end

  describe '#validate with VIES test enviroment' do
    let(:options) do
      { skip_local_validation: true }
    end

    before do
      stub_const('Valvat::Lookup::VIES::ENDPOINT_URI', URI('https://ec.europa.eu/taxation_customs/vies/test-services/checkVatTestService'))
    end

    context 'with valid request with valid VAT number' do
      subject(:result) { described_class.validate('DE100', options) }

      it 'returns true' do
        expect(result).to be(true)
      end
    end

    context 'with valid request with an invalid VAT number' do
      subject(:result) { described_class.validate('DE200', options) }

      it 'returns false' do
        expect(result).to be(false)
      end
    end

    describe 'Error : INVALID_INPUT' do
      subject(:result) { described_class.validate('DE201', options) }

      it 'returns false' do
        expect(result).to be(false)
      end
    end

    describe 'Error : INVALID_REQUESTER_INFO' do
      subject(:result) { described_class.validate('DE202', options) }

      it 'raises Valvat::InvalidRequester' do
        expect { result }.to raise_error(Valvat::InvalidRequester)
      end
    end

    describe 'Error : SERVICE_UNAVAILABLE' do
      subject(:result) { described_class.validate('DE300', options) }

      it 'returns nil' do
        expect(result).to be_nil
      end

      it 'raises error with raise_error: true' do
        expect do
          described_class.validate('DE300', options.merge(raise_error: true))
        end.to raise_error(Valvat::ServiceUnavailable)
      end
    end

    describe 'Error : MS_UNAVAILABLE' do
      subject(:result) { described_class.validate('DE301', options) }

      it 'returns nil' do
        expect(result).to be_nil
      end

      it 'raises error with raise_error: true' do
        expect do
          described_class.validate('DE301', options.merge(raise_error: true))
        end.to raise_error(Valvat::MemberStateUnavailable)
      end
    end

    describe 'Error : TIMEOUT' do
      subject(:result) { described_class.validate('DE302', options) }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::Timeout)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('DE302', options.merge(raise_error: false))).to be_nil
      end
    end

    describe 'Network timeout' do
      subject(:result) { described_class.validate('DE200', options) }

      before { stub_request(:post, /ec.europa.eu/).to_timeout }

      it 'raises error' do
        expect { result }.to raise_error(Net::OpenTimeout, 'execution expired')
      end

      it 'also raises error with raise_error set to false (not handled)' do
        expect do
          described_class.validate('DE302', options.merge(raise_error: false))
        end.to raise_error(Net::OpenTimeout, 'execution expired')
      end
    end

    describe 'Error : VAT_BLOCKED' do
      subject(:result) { described_class.validate('DE400', options) }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::BlockedError, /VAT_BLOCKED/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('DE400', options.merge(raise_error: false))).to be_nil
      end
    end

    describe 'Error : IP_BLOCKED' do
      subject(:result) { described_class.validate('DE401', options) }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::BlockedError, /IP_BLOCKED/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('DE401', options.merge(raise_error: false))).to be_nil
      end
    end

    describe 'Error : GLOBAL_MAX_CONCURRENT_REQ' do
      subject(:result) { described_class.validate('DE500', options) }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::RateLimitError, /GLOBAL_MAX_CONCURRENT_REQ/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('DE500', options.merge(raise_error: false))).to be_nil
      end
    end

    describe 'Error : GLOBAL_MAX_CONCURRENT_REQ_TIME' do
      subject(:result) { described_class.validate('DE501', options) }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::RateLimitError, /GLOBAL_MAX_CONCURRENT_REQ_TIME/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('DE501', options.merge(raise_error: false))).to be_nil
      end
    end

    describe 'Error : MS_MAX_CONCURRENT_REQ' do
      subject(:result) { described_class.validate('DE600', options) }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::RateLimitError, /MS_MAX_CONCURRENT_REQ/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('DE600', options.merge(raise_error: false))).to be_nil
      end
    end

    describe 'Error : MS_MAX_CONCURRENT_REQ_TIME' do
      subject(:result) { described_class.validate('DE601', options) }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::RateLimitError, /MS_MAX_CONCURRENT_REQ_TIME/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('DE601', options.merge(raise_error: false))).to be_nil
      end
    end

    describe 'Error : HTTP error' do
      subject(:result) { described_class.validate('DE601', options) }

      before do
        stub_request(:post, %r{\Ahttps://ec\.europa\.eu}).to_return({ status: 405 })
      end

      it 'raises error' do
        expect { result }.to raise_error(Valvat::HTTPError, 'The VIES web service returned the error: 405')
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('DE601', options.merge(raise_error: false))).to be_nil
      end
    end
  end

  describe '#validate with HMRC test enviroment' do
    # https://developer.service.hmrc.gov.uk/api-documentation/docs/testing
    # https://github.com/hmrc/vat-registered-companies-api/blob/master/public/api/conf/1.0/test-data/vrn.csv
    subject(:result) { described_class.validate("GB#{vat_number}") }

    include_context 'with hmrc configuration'

    let(:vat_number) { '123456789' }

    context 'with valid request with valid VAT number' do
      context 'when VAT is 553557881' do
        let(:vat_number) { '553557881' }

        it 'returns true' do
          expect(result).to be(true)
        end
      end

      context 'when VAT is 146295999727' do
        let(:vat_number) { '146295999727' }

        it 'returns true' do
          expect(result).to be(true)
        end
      end
    end

    context 'with valid request with an invalid VAT number' do
      let(:lookup_response) do
        {
          status: 404,
          body: {
            code: 'NOT_FOUND',
            message: 'targetVrn does not match a registered company'
          }.to_json
        }
      end

      it 'returns false' do
        expect(result).to be(false)
      end
    end

    describe 'Error : MESSAGE_THROTTLED_OUT' do
      let(:lookup_response) do
        {
          status: 429,
          body: {
            code: 'MESSAGE_THROTTLED_OUT'
          }.to_json
        }
      end

      it 'raises error' do
        expect { result }.to raise_error(Valvat::RateLimitError, /MESSAGE_THROTTLED_OUT/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('GB123456789', raise_error: false)).to be_nil
      end
    end

    describe 'Error : SCHEDULED_MAINTENANCE' do
      let(:lookup_response) do
        {
          status: 503,
          body: {
            code: 'SCHEDULED_MAINTENANCE'
          }.to_json
        }
      end

      it 'returns nil' do
        expect(result).to be_nil
      end

      it 'raises error with raise_error set to false' do
        expect do
          described_class.validate('GB123456789', raise_error: true)
        end.to raise_error(Valvat::ServiceUnavailable, 'The HMRC web service returned the error: SCHEDULED_MAINTENANCE')
      end
    end

    describe 'Error : SERVER_ERROR' do
      let(:lookup_response) do
        {
          status: 503,
          body: {
            code: 'SERVER_ERROR'
          }.to_json
        }
      end

      it 'returns nil' do
        expect(result).to be_nil
      end

      it 'raises error with raise_error set to false' do
        expect do
          described_class.validate('GB123456789', raise_error: true)
        end.to raise_error(Valvat::ServiceUnavailable, 'The HMRC web service returned the error: SERVER_ERROR')
      end
    end

    describe 'Error : GATEWAY_TIMEOUT' do
      let(:lookup_response) do
        {
          status: 504,
          body: {
            code: 'GATEWAY_TIMEOUT'
          }.to_json
        }
      end

      it 'raises error' do
        expect { result }.to raise_error(Valvat::Timeout, /GATEWAY_TIMEOUT/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('GB123456789', raise_error: false)).to be_nil
      end
    end

    describe 'Network timeout' do
      before do
        stub_request(:get, /test-api\.service\.hmrc\.gov\.uk/).to_timeout
      end

      it 'raises error' do
        expect { result }.to raise_error(Net::OpenTimeout)
      end

      it 'also raises error with raise_error set to false (not handled)' do
        expect do
          described_class.validate('GB123456789', raise_error: false)
        end.to raise_error(Net::OpenTimeout)
      end
    end

    describe 'Error : INTERNAL_SERVER_ERROR' do
      let(:lookup_response) do
        {
          status: 504,
          body: {
            code: 'INTERNAL_SERVER_ERROR'
          }.to_json
        }
      end

      it 'raises error' do
        expect { result }.to raise_error(Valvat::UnknownLookupError, /INTERNAL_SERVER_ERROR/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('GB123456789', raise_error: false)).to be_nil
      end
    end

    describe 'Error : INVALID_CREDENTIALS' do
      let(:lookup_response) do
        {
          status: 401,
          body: {
            code: 'INVALID_CREDENTIALS',
            message: 'Invalid Authentication information provided'
          }.to_json
        }
      end

      it 'raises error' do
        expect do
          result
        end.to raise_error(
          Valvat::AuthorizationError,
          'The HMRC web service returned the error: INVALID_CREDENTIALS (Invalid Authentication information provided)'
        )
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('GB123456789', raise_error: false)).to be_nil
      end
    end

    describe 'Valvat::HMRC::AccessToken::Error : invalid_client' do
      let(:authentication_response) do
        {
          status: 401,
          body: {
            error: 'invalid_client',
            error_description: 'invalid client id or secret'
          }.to_json
        }
      end

      it 'raises error' do
        expect do
          result
        end.to raise_error(
          Valvat::HMRC::AccessToken::Error,
          'Failed to fetch access token: invalid client id or secret'
        )
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('GB123456789', raise_error: false)).to be_nil
      end
    end
  end
end
