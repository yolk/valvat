# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Lookup do
  describe '#validate' do
    context 'with existing EU VAT number' do
      it 'returns true' do
        result = described_class.validate('IE6388047V')
        skip "VIES is down" if result.nil?
        expect(result).to be(true)
      end

      it 'allows Valvat instance as input' do
        result = described_class.validate(Valvat.new('IE6388047V'))
        skip "VIES is down" if result.nil?
        expect(result).to be(true)
      end
    end

    context 'with existing GB VAT number' do
      it 'returns true' do
        result = described_class.validate('GB727255821')
        skip "HMRC is down" if result.nil?
        expect(result).to be(true)
      end

      it 'returns details in format similar to VIES' do
        result = described_class.validate('GB727255821', detail: true)
        skip "HMRC is down" if result.nil?
        expect(result).to match({
          request_date: kind_of(Time),
          country_code: 'GB',
          vat_number: '727255821',
          name: 'AMAZON EU SARL',
          address: "1 PRINCIPAL PLACE\nWORSHIP STREET\nLONDON\nEC2A 2FA\nGB",
          valid: true
        })
      end
    end

    context 'with not existing EU VAT number' do
      it 'returns false' do
        result =  described_class.validate('IE6388048V')
        skip "VIES is down" if result.nil?
        expect(result).to be(false)
      end
    end

    context 'with not existing GB VAT number' do
      it 'returns false' do
        result =  described_class.validate('GB727255820')
        skip "HMRC is down" if result.nil?
        expect(result).to be(false)
      end
    end

    context 'with invalid country code / input' do
      it 'returns false' do
        expect(described_class.validate('AE259597697')).to be(false)
        expect(described_class.validate('')).to be(false)
      end
    end

    context 'with details' do
      let(:details) do
        {
          country_code: 'IE',
          vat_number: '6388047V',
          name: 'GOOGLE IRELAND LIMITED',
          address: '3RD FLOOR, GORDON HOUSE, BARROW STREET, DUBLIN 4',
          valid: true
        }
      end

      it 'returns hash of details instead of true' do
        result = described_class.validate('IE6388047V', detail: true)
        skip "VIES is down" if result.nil?
        expect(result.delete(:request_date)).to be_kind_of(Date)
        expect(result).to eql(details)
      end

      it 'still returns false on not existing VAT number' do
        result = described_class.validate('LU21416128', detail: true)
        skip "VIES is down" if result.nil?
        expect(result).to be(false)
      end
    end

    context 'with request identifier' do
      it 'returns hash of details instead of true' do
        response = described_class.validate('IE6388047V', requester: 'IE6388047V')
        skip "VIES is down" if response.nil?
        expect(response.delete(:request_identifier).size).to be(16)
        expect(response.delete(:request_date)).to be_kind_of(Date)
        expect(response).to eql({
          country_code: 'IE',
          vat_number: '6388047V',
          name: 'GOOGLE IRELAND LIMITED',
          company_type: nil,
          address: '3RD FLOOR, GORDON HOUSE, BARROW STREET, DUBLIN 4',
          valid: true
        })
      end

      it 'supports old :requester_vat option for backwards stability' do
        expect(
          described_class.new('IE6388047V', requester_vat: 'LU21416127').instance_variable_get(:@options)[:requester]
        ).to eql('LU21416127')
      end

      context 'with GB VAT number' do
        it 'returns hash of details with request number' do
          response = described_class.validate('GB727255821', requester: 'GB727255821')
          skip "HMRC is down" if response.nil?
          expect(response).to match({
            request_date: kind_of(Time),
            request_identifier: /\A\w\w\w-\w\w\w-\w\w\w\Z/,
            country_code: 'GB',
            vat_number: '727255821',
            name: 'AMAZON EU SARL',
            address: "1 PRINCIPAL PLACE\nWORSHIP STREET\nLONDON\nEC2A 2FA\nGB",
            valid: true
          })
        end

        it 'raises exception if requester is not from GB' do
          expect {
            described_class.validate('GB727255821', requester: 'IE6388047V')
          }.to raise_error(Valvat::InvalidRequester, "Requester must be a GB number when checking GB VAT numbers.")
        end

        it 'raises exception if requester is not valid' do
          expect {
            described_class.validate('GB727255821', requester: 'GB6388047')
          }.to raise_error(Valvat::InvalidRequester, "The HMRC web service returned the error 'INVALID_REQUEST' (Invalid requesterVrn - Vrn parameters should be 9 or 12 digits).")
        end
      end
    end
  end

  describe '#validate with VIES test enviroment' do
    let(:options) do
      { savon: { wsdl: 'https://ec.europa.eu/taxation_customs/vies/checkVatTestService.wsdl' },
        skip_local_validation: true }
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
        expect(result).to be(nil)
      end

      it 'raises error with raise_error: true' do
        expect do
          described_class.validate('DE300', options.merge(raise_error: true))
        end.to raise_error(Valvat::ServiceUnavailable, "The VIES web service returned the error 'SERVICE_UNAVAILABLE'.")
      end
    end

    describe 'Error : MS_UNAVAILABLE' do
      subject(:result) { described_class.validate('DE301', options) }

      it 'returns nil' do
        expect(result).to be(nil)
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
        expect(described_class.validate('DE302', options.merge(raise_error: false))).to be(nil)
      end
    end

    describe 'Network timeout' do
      subject(:result) { described_class.validate('DE200', options) }
      before { stub_request(:get, /ec.europa.eu/).to_timeout }

      it 'raises error' do
        expect { result }.to raise_error(Net::OpenTimeout, "execution expired")
      end

      it 'also raises error with raise_error set to false (not handled)' do
        expect {
          described_class.validate('DE302', options.merge(raise_error: false))
        }.to raise_error(Net::OpenTimeout, "execution expired")
      end
    end

    describe 'Error : VAT_BLOCKED' do
      subject(:result) { described_class.validate('DE400', options) }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::BlockedError, /VAT_BLOCKED/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('DE400', options.merge(raise_error: false))).to be(nil)
      end
    end

    describe 'Error : IP_BLOCKED' do
      subject(:result) { described_class.validate('DE401', options) }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::BlockedError, /IP_BLOCKED/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('DE401', options.merge(raise_error: false))).to be(nil)
      end
    end

    describe 'Error : GLOBAL_MAX_CONCURRENT_REQ' do
      subject(:result) { described_class.validate('DE500', options) }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::RateLimitError, /GLOBAL_MAX_CONCURRENT_REQ/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('DE500', options.merge(raise_error: false))).to be(nil)
      end
    end

    describe 'Error : GLOBAL_MAX_CONCURRENT_REQ_TIME' do
      subject(:result) { described_class.validate('DE501', options) }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::RateLimitError, /GLOBAL_MAX_CONCURRENT_REQ_TIME/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('DE501', options.merge(raise_error: false))).to be(nil)
      end
    end

    describe 'Error : MS_MAX_CONCURRENT_REQ' do
      subject(:result) { described_class.validate('DE600', options) }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::RateLimitError, /MS_MAX_CONCURRENT_REQ/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('DE600', options.merge(raise_error: false))).to be(nil)
      end
    end

    describe 'Error : MS_MAX_CONCURRENT_REQ_TIME' do
      subject(:result) { described_class.validate('DE601', options) }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::RateLimitError, /MS_MAX_CONCURRENT_REQ_TIME/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('DE601', options.merge(raise_error: false))).to be(nil)
      end
    end
  end

  describe '#validate with HMRC test enviroment' do
    # https://developer.service.hmrc.gov.uk/api-documentation/docs/testing
    # https://github.com/hmrc/vat-registered-companies-api/blob/master/public/api/conf/1.0/test-data/vrn.csv
    before do
      stub_const('Valvat::Lookup::HMRC::Request::HMRC_API_URL', 'https://test-api.service.hmrc.gov.uk/organisations/vat/check-vat-number/lookup')
    end

    subject(:result) { described_class.validate('GB123456789') }

    context 'with valid request with valid VAT number' do
      it 'returns true' do
        expect(described_class.validate('GB553557881')).to be(true)
        expect(described_class.validate('GB146295999727')).to be(true)
      end
    end

    context 'with valid request with an invalid VAT number' do
      it 'returns false' do
        expect(result).to be(false)
      end
    end

    describe 'Error : MESSAGE_THROTTLED_OUT' do
      before {
        stub_request(:get, /test-api.service.hmrc.gov.uk/).to_return(
          status: 429,
          body: '{"code":"MESSAGE_THROTTLED_OUT"}'
        )
      }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::RateLimitError, /MESSAGE_THROTTLED_OUT/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('GB123456789', raise_error: false)).to be(nil)
      end
    end

    describe 'Error : SCHEDULED_MAINTENANCE' do
      before {
        stub_request(:get, /test-api.service.hmrc.gov.uk/).to_return(
          status: 503,
          body: '{"code":"SCHEDULED_MAINTENANCE"}'
        )
      }

      it 'returns nil' do
        expect(result).to be(nil)
      end

      it 'raises error with raise_error set to false' do
        expect {
          described_class.validate('GB123456789', raise_error: true)
        }.to raise_error(Valvat::ServiceUnavailable, "The HMRC web service returned the error 'SCHEDULED_MAINTENANCE' ().")
      end
    end

    describe 'Error : SERVER_ERROR' do
      before {
        stub_request(:get, /test-api.service.hmrc.gov.uk/).to_return(
          status: 503,
          body: '{"code":"SERVER_ERROR"}'
        )
      }

      it 'returns nil' do
        expect(result).to be(nil)
      end

      it 'raises error with raise_error set to false' do
        expect {
          described_class.validate('GB123456789', raise_error: true)
        }.to raise_error(Valvat::ServiceUnavailable, "The HMRC web service returned the error 'SERVER_ERROR' ().")
      end
    end

    describe 'Error : GATEWAY_TIMEOUT' do
      before {
        stub_request(:get, /test-api.service.hmrc.gov.uk/).to_return(
          status: 504,
          body: '{"code":"GATEWAY_TIMEOUT"}'
        )
      }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::Timeout, /GATEWAY_TIMEOUT/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('GB123456789', raise_error: false)).to be(nil)
      end
    end

    describe 'Network timeout' do
      before {
        stub_request(:get, /test-api.service.hmrc.gov.uk/).to_timeout
      }

      it 'raises error' do
        expect { result }.to raise_error(Net::OpenTimeout)
      end

      it 'also raises error with raise_error set to false (not handled)' do
        expect {
          described_class.validate('GB123456789', raise_error: false)
        }.to raise_error(Net::OpenTimeout)
      end
    end

    describe 'Error : INTERNAL_SERVER_ERROR' do
      before {
        stub_request(:get, /test-api.service.hmrc.gov.uk/).to_return(
          status: 500,
          body: '{"code":"INTERNAL_SERVER_ERROR"}'
        )
      }

      it 'raises error' do
        expect { result }.to raise_error(Valvat::UnknownLookupError, /INTERNAL_SERVER_ERROR/)
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('GB123456789', raise_error: false)).to be(nil)
      end
    end
  end
end
