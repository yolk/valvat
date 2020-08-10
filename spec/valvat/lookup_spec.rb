require 'spec_helper'

describe Valvat::Lookup do
  describe "#validate" do
    context "existing VAT number" do

      it "returns true" do
        result = Valvat::Lookup.validate("IE6388047V")

        unless result.nil?
          expect(result).to eql(true)
        else
          puts "Skipping IE vies lookup spec"
        end
      end

      it "allows Valvat instance as input" do
        result = Valvat::Lookup.validate(Valvat.new("IE6388047V"))

        unless result.nil?
          expect(result).to eql(true)
        else
          puts "Skipping IE vies lookup spec"
        end
      end
    end

    context "not existing VAT number" do
      it "returns false" do
        result =  Valvat::Lookup.validate("IE6388048V")

        unless result.nil?
          expect(result).to eql(false)
        else
          puts "Skipping IE vies lookup spec"
        end
      end
    end

    context "invalid country code / input" do
      it "returns false" do
        expect(Valvat::Lookup.validate("AE259597697")).to eql(false)
        expect(Valvat::Lookup.validate("")).to eql(false)
      end
    end

    context "with details" do
      it "returns hash of details instead of true" do
        result = Valvat::Lookup.validate("IE6388047V", detail: true)

         if result
          expect(result.delete(:request_date)).to be_kind_of(Date)
          expect(result).to eql({
            country_code: "IE",
            vat_number: "6388047V",
            name: "GOOGLE IRELAND LIMITED",
            address: "3RD FLOOR, GORDON HOUSE, BARROW STREET, DUBLIN 4",
            valid: true
          })
        else
          puts "Skipping IE vies lookup spec; result = #{result.inspect}"
        end
      end

      it "still returns false on not existing VAT number" do
        result =  Valvat::Lookup.validate("LU21416128", detail: true)

        unless result.nil?
          expect(result).to eql(false)
        else
          puts "Skipping LU vies lookup spec"
        end
      end
    end

    context "with request identifier" do
      it "returns hash of details instead of true" do
        response = Valvat::Lookup.validate("IE6388047V", requester: "IE6388047V")

        if response
          expect(response[:request_identifier].size).to eql(16)
          request_identifier = response[:request_identifier]
          expect(response.delete(:request_date)).to be_kind_of(Date)
          expect(response).to eql({
            country_code: "IE",
            vat_number: "6388047V",
            name: "GOOGLE IRELAND LIMITED",
            company_type:nil,
            address: "3RD FLOOR, GORDON HOUSE, BARROW STREET, DUBLIN 4",
            request_identifier: request_identifier,
            valid: true
          })
        else
          puts "Skipping IE vies lookup spec"
        end
      end

      it "supports old :requester_vat option for backwards stability" do
        expect(
          Valvat::Lookup.new("IE6388047V", requester_vat: "LU21416127").instance_variable_get(:@options)[:requester]
        ).to eql("LU21416127")

        expect(
          Valvat::Lookup.new("IE6388047V", requester: "LU21416128").instance_variable_get(:@options)[:requester]
        ).to eql("LU21416128")
      end
    end
  end

  describe "#validate with VIES test enviroment" do

    let(:options) { {savon: {wsdl: "https://ec.europa.eu/taxation_customs/vies/checkVatTestService.wsdl"}, skip_local_validation: true} }

    context "Valid request with Valid VAT Number" do
      subject{ Valvat::Lookup.validate("DE100", options) }

      it "returns true" do
        expect(subject).to eql(true)
      end
    end

    context "Valid request with an Invalid VAT Number" do
      subject{ Valvat::Lookup.validate("DE200", options) }

      it "returns false" do
        expect(subject).to eql(false)
      end
    end

    context "Error : INVALID_INPUT" do
      subject{ Valvat::Lookup.validate("DE201", options) }

      it "returns false" do
        expect(subject).to eql(false)
      end
    end

    context "Error : INVALID_REQUESTER_INFO" do
      subject{ Valvat::Lookup.validate("DE202", options) }

      it "raises Valvat::InvalidRequester" do
        expect{ subject }.to raise_error(Valvat::InvalidRequester)
      end
    end

    context "Error : SERVICE_UNAVAILABLE" do
      subject{ Valvat::Lookup.validate("DE300", options) }

      it "returns nil" do
        expect(subject).to eql(nil)
      end

      it "raises error with raise_error: true" do
        expect{
          Valvat::Lookup.validate("DE300", options.merge(raise_error: true)
        ) }.to raise_error(Valvat::ServiceUnavailable)
      end
    end

    context "Error : MS_UNAVAILABLE" do
      subject{ Valvat::Lookup.validate("DE301", options) }

      it "returns nil" do
        expect(subject).to eql(nil)
      end

      it "raises error with raise_error: true" do
        expect{
          Valvat::Lookup.validate("DE301", options.merge(raise_error: true)
        ) }.to raise_error(Valvat::MemberStateUnavailable)
      end
    end

    context "Error : TIMEOUT" do
      subject{ Valvat::Lookup.validate("DE302", options) }

      it "raises error" do
        expect{ subject }.to raise_error(Valvat::Timeout)
      end

      it "returns nil with raise_error set to false" do
        expect(Valvat::Lookup.validate("DE302", options.merge(raise_error: false))).to eql(nil)
      end
    end

    context "Error : VAT_BLOCKED" do
      subject{ Valvat::Lookup.validate("DE400", options) }

      it "raises error" do
        expect{ subject }.to raise_error(Valvat::BlockedError, /VAT_BLOCKED/)
      end

      it "returns nil with raise_error set to false" do
        expect(Valvat::Lookup.validate("DE400", options.merge(raise_error: false))).to eql(nil)
      end
    end

    context "Error : IP_BLOCKED" do
      subject{ Valvat::Lookup.validate("DE401", options) }

      it "raises error" do
        expect{ subject }.to raise_error(Valvat::BlockedError, /IP_BLOCKED/)
      end

      it "returns nil with raise_error set to false" do
        expect(Valvat::Lookup.validate("DE401", options.merge(raise_error: false))).to eql(nil)
      end
    end

    context "Error : GLOBAL_MAX_CONCURRENT_REQ" do
      subject{ Valvat::Lookup.validate("DE500", options) }

      it "raises error" do
        expect{ subject }.to raise_error(Valvat::RateLimitError, /GLOBAL_MAX_CONCURRENT_REQ/)
      end

      it "returns nil with raise_error set to false" do
        expect(Valvat::Lookup.validate("DE500", options.merge(raise_error: false))).to eql(nil)
      end
    end

    context "Error : GLOBAL_MAX_CONCURRENT_REQ_TIME" do
      subject{ Valvat::Lookup.validate("DE501", options) }

      it "raises error" do
        expect{ subject }.to raise_error(Valvat::RateLimitError, /GLOBAL_MAX_CONCURRENT_REQ_TIME/)
      end

      it "returns nil with raise_error set to false" do
        expect(Valvat::Lookup.validate("DE501", options.merge(raise_error: false))).to eql(nil)
      end
    end

    context "Error : MS_MAX_CONCURRENT_REQ" do
      subject{ Valvat::Lookup.validate("DE600", options) }

      it "raises error" do
        expect{ subject }.to raise_error(Valvat::RateLimitError, /MS_MAX_CONCURRENT_REQ/)
      end

      it "returns nil with raise_error set to false" do
        expect(Valvat::Lookup.validate("DE600", options.merge(raise_error: false))).to eql(nil)
      end
    end

    context "Error : MS_MAX_CONCURRENT_REQ_TIME" do
      subject{ Valvat::Lookup.validate("DE601", options) }

      it "raises error" do
        expect{ subject }.to raise_error(Valvat::RateLimitError, /MS_MAX_CONCURRENT_REQ_TIME/)
      end

      it "returns nil with raise_error set to false" do
        expect(Valvat::Lookup.validate("DE601", options.merge(raise_error: false))).to eql(nil)
      end
    end
  end
end
