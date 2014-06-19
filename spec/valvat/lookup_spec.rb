require 'spec_helper'

describe Valvat::Lookup do
  describe "#validate" do
    context "existing vat number" do

      it "returns true" do
        result = Valvat::Lookup.validate("LU21416127")

        unless result.nil?
          expect(result).to eql(true)
        else
          puts "Skipping LU vies lookup spec"
        end
      end

      it "allows Valvat instance as input" do
        result = Valvat::Lookup.validate(Valvat.new("LU21416127"))

        unless result.nil?
          expect(result).to eql(true)
        else
          puts "Skipping LU vies lookup spec"
        end
      end
    end

    context "not existing vat number" do
      it "returns false" do
        result =  Valvat::Lookup.validate("LU21416128")

        unless result.nil?
          expect(result).to eql(false)
        else
          puts "Skipping LU vies lookup spec"
        end
      end
    end

    context "invalid country code / input" do
      without_any_web_requests!

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
            :address=>"3RD FLOOR ,GORDON HOUSE ,BARROW STREET ,DUBLIN 4"
          })
        else
          puts "Skipping IE vies lookup spec; result = #{result.inspect}"
        end

        result = Valvat::Lookup.validate("LU21416127", :detail => true)

        if result
          expect(result.delete(:request_date)).to be_kind_of(Date)
          expect(result).to eql({
            :country_code=>"LU",
            :vat_number=>"21416127",
            :name=>"EBAY EUROPE S.A R.L.",
            :address=>"22, BOULEVARD ROYAL\nL-2449  LUXEMBOURG"
          })
        else
          puts "Skipping LU vies lookup spec; result = #{result.inspect}"
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
        response = Valvat::Lookup.validate("LU21416127", :requester_vat => "IE6388047V")

        if response
          expect(response[:request_identifier].size).to eql(16)
          request_identifier = response[:request_identifier]
          expect(response.delete(:request_date)).to be_kind_of(Date)
          expect(response).to eql({
            :country_code=>"LU",
            :vat_number=>"21416127",
            :name => "EBAY EUROPE S.A R.L.",
            :company_type=>nil,
            :address => "22, BOULEVARD ROYAL\nL-2449  LUXEMBOURG",
            :request_identifier=> request_identifier
          })
        else
          puts "Skipping LU vies lookup spec"
        end
      end
    end

    context "error on request" do
      before do
        @request = double("request")
        allow(Valvat::Lookup::Request).to receive_messages(:new => @request)
        allow(@request).to receive(:perform).and_raise(ArgumentError.new)
      end

      it "should return nil" do
        expect(Valvat::Lookup.validate("LU21416127")).to eql(nil)
      end

      it "should raise error with raise_error option" do
        expect {Valvat::Lookup.validate("LU21416127", :raise_error => true)}.to raise_error(ArgumentError)
      end
    end

    # TODO : Reactivate with coorect "down" response
    # context "country web service down" do
    #   before do
    #     json = "{\"error_message\": \"Member State service unavailable.\", \"error_code\": 1, \"error\": true}"
    #     FakeWeb.register_uri(:get, "http://isvat.appspot.com/DE/259597697/", :body => json)
    #   end if $fakeweb

    #   it "returns nil" do
    #     Valvat::Lookup.validate("DE259597697").should eql(nil)
    #   end
    # end
  end
end
