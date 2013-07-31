require 'spec_helper'

describe Valvat::Lookup do
  describe "#validate" do
    context "existing vat number" do

      it "returns true" do
        Valvat::Lookup.validate("DE259597697").should eql(true)
      end

      it "allows Valvat instance as input" do
        Valvat::Lookup.validate(Valvat.new("DE259597697")).should eql(true)
      end
    end

    context "not existing vat number" do
      it "returns false" do
        Valvat::Lookup.validate("DE259597696").should eql(false)
      end
    end

    context "invalid country code / input" do
      without_any_web_requests!

      it "returns false" do
        Valvat::Lookup.validate("AE259597697").should eql(false)
        Valvat::Lookup.validate("").should eql(false)
      end
    end

    context "with details" do
      it "returns hash of details instead of true" do
        result = Valvat::Lookup.validate("IE6388047V", :detail => true)

         if result
          result.delete(:request_date).should be_kind_of(Date)
          result.should eql({
            :country_code=>"IE",
            :vat_number=>"6388047V",
            :name=>"GOOGLE IRELAND LIMITED",
            :address=>"1ST & 2ND FLOOR ,GORDON HOUSE ,BARROW STREET ,DUBLIN 4"
          })
        else
          puts "Skipping IE vies lookup spec; result = #{result.inspect}"
        end

        result = Valvat::Lookup.validate("LU21416127", :detail => true)

        if result
          result.delete(:request_date).should be_kind_of(Date)
          result.should eql({
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
        Valvat::Lookup.validate("DE259597696", :detail => true).should eql(false)
      end
    end

    context "with request identifier" do
      it "returns hash of details instead of true" do
        response = Valvat::Lookup.validate("DE259597697", :requester_vat => "IE6388047V")
        response[:request_identifier].size.should eql(16)
        request_identifier = response[:request_identifier]
        response.delete(:request_date).should be_kind_of(Date)
        response.should eql({
          :country_code=>"DE",
          :vat_number=>"259597697",
          :name => nil,
          :company_type=>nil,
          :request_identifier=> request_identifier
        })
      end
    end

    context "error on request" do
      before do
        @request = double("request")
        Valvat::Lookup::Request.stub(:new => @request)
        @request.stub(:perform).and_raise(ArgumentError.new)
      end

      it "should return nil" do
        Valvat::Lookup.validate("LU21416127").should eql(nil)
      end

      it "should raise error with raise_error option" do
        lambda {Valvat::Lookup.validate("LU21416127", :raise_error => true)}.should raise_error(ArgumentError)
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
