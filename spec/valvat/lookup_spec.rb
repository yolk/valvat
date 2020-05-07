require 'spec_helper'

describe Valvat::Lookup do
  describe "#validate" do
    context "existing vat number" do

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

    context "not existing vat number" do
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
        result = Valvat::Lookup.validate("IE6388047V", :detail => true)

         if result
          expect(result.delete(:request_date)).to be_kind_of(Date)
          expect(result).to eql({
            :country_code=>"IE",
            :vat_number=>"6388047V",
            :name=>"GOOGLE IRELAND LIMITED",
            :address=>"3RD FLOOR, GORDON HOUSE, BARROW STREET, DUBLIN 4",
            :valid=>true
          })
        else
          puts "Skipping IE vies lookup spec; result = #{result.inspect}"
        end
      end

      it "still returns false on not existing vat number" do
        result =  Valvat::Lookup.validate("LU21416128", :detail => true)

        unless result.nil?
          expect(result).to eql(false)
        else
          puts "Skipping LU vies lookup spec"
        end
      end
    end

    context "with request identifier" do
      it "returns hash of details instead of true" do
        response = Valvat::Lookup.validate("IE6388047V", :requester_vat => "IE6388047V")

        if response
          expect(response[:request_identifier].size).to eql(16)
          request_identifier = response[:request_identifier]
          expect(response.delete(:request_date)).to be_kind_of(Date)
          expect(response).to eql({
            :country_code=>"IE",
            :vat_number=>"6388047V",
            :name => "GOOGLE IRELAND LIMITED",
            :company_type=>nil,
            :address => "3RD FLOOR, GORDON HOUSE, BARROW STREET, DUBLIN 4",
            :request_identifier=> request_identifier,
            :valid=>true
          })
        else
          puts "Skipping IE vies lookup spec"
        end
      end
    end
  end

  describe "#validate with VIES test enviroment" do
    # Here is the list of VAT Number to use to receive each kind of answer :
    #
    # 100 = Valid request with Valid VAT Number
    # 200 = Valid request with an Invalid VAT Number
    # 201 = Error : INVALID_INPUT
    # 202 = Error : INVALID_REQUESTER_INFO
    # 300 = Error : SERVICE_UNAVAILABLE
    # 301 = Error : MS_UNAVAILABLE
    # 302 = Error : TIMEOUT
    # 400 = Error : VAT_BLOCKED
    # 401 = Error : IP_BLOCKED
    # 500 = Error : GLOBAL_MAX_CONCURRENT_REQ
    # 501 = Error : GLOBAL_MAX_CONCURRENT_REQ_TIME
    # 600 = Error : MS_MAX_CONCURRENT_REQ
    # 601 = Error : MS_MAX_CONCURRENT_REQ_TIME

    let(:options) { {wsdl: "https://ec.europa.eu/taxation_customs/vies/checkVatTestService.wsdl", skip_local_validation: true} }

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

      it "returns nil" do
        expect(subject).to eql(nil)
      end
    end

    context "Error : SERVICE_UNAVAILABLE" do
      subject{ Valvat::Lookup.validate("DE300", options) }

      it "returns nil" do
        expect(subject).to eql(nil)
      end
    end

    context "Error : MS_UNAVAILABLE" do
      subject{ Valvat::Lookup.validate("DE301", options) }

      it "returns nil" do
        expect(subject).to eql(nil)
      end
    end

    context "Error : TIMEOUT" do
      subject{ Valvat::Lookup.validate("DE302", options) }

      it "returns nil" do
        expect(subject).to eql(nil)
      end
    end

    context "Error : VAT_BLOCKED" do
      subject{ Valvat::Lookup.validate("DE400", options) }

      it "returns nil" do
        expect(subject).to eql(nil)
      end
    end

    context "Error : IP_BLOCKED" do
      subject{ Valvat::Lookup.validate("DE401", options) }

      it "returns nil" do
        expect(subject).to eql(nil)
      end
    end

    context "Error : GLOBAL_MAX_CONCURRENT_REQ" do
      subject{ Valvat::Lookup.validate("DE500", options) }

      it "returns nil" do
        expect(subject).to eql(nil)
      end
    end

    context "Error : GLOBAL_MAX_CONCURRENT_REQ_TIME" do
      subject{ Valvat::Lookup.validate("DE501", options) }

      it "returns nil" do
        expect(subject).to eql(nil)
      end
    end

    context "Error : MS_MAX_CONCURRENT_REQ" do
      subject{ Valvat::Lookup.validate("DE600", options) }

      it "returns nil" do
        expect(subject).to eql(nil)
      end
    end

    context "Error : MS_MAX_CONCURRENT_REQ_TIME" do
      subject{ Valvat::Lookup.validate("DE601", options) }

      it "returns nil" do
        expect(subject).to eql(nil)
      end
    end
  end
end
