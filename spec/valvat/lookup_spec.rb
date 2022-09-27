# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Lookup do
  before do
    WebMock.allow_net_connect!
  end

  describe '#validate' do
    context 'with existing VAT number' do
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

    context 'with not existing VAT number' do
      it 'returns false' do
        result =  described_class.validate('IE6388048V')
        skip "VIES is down" if result.nil?
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
      let(:response) { described_class.validate('IE6388047V', requester: 'IE6388047V') }
      let(:details) do
        {
          country_code: 'IE',
          vat_number: '6388047V',
          name: 'GOOGLE IRELAND LIMITED',
          company_type: nil,
          address: '3RD FLOOR, GORDON HOUSE, BARROW STREET, DUBLIN 4',
          valid: true
        }
      end

      it 'returns hash of details instead of true' do
        skip "VIES is down" if result.nil?

        expect(response.delete(:request_identifier).size).to be(16)
        expect(response.delete(:request_date)).to be_kind_of(Date)
        expect(response).to eql(details)
      end

      it 'supports old :requester_vat option for backwards stability' do
        expect(
          described_class.new('IE6388047V', requester_vat: 'LU21416127').instance_variable_get(:@options)[:requester]
        ).to eql('LU21416127')
      end
    end
  end

  describe '#validate with VIES test enviroment' do
    let(:options) do
      { vies_url: 'https://ec.europa.eu/taxation_customs/vies/test-services/checkVatTestService',
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
        expect { result }.to raise_error(Valvat::HTTPError, "The VIES web service returned the HTTP status code '405'.")
      end

      it 'returns nil with raise_error set to false' do
        expect(described_class.validate('DE601', options.merge(raise_error: false))).to be_nil
      end
    end
  end
end
