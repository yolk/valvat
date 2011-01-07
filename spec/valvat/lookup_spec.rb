require 'spec_helper'

describe Valvat::Lookup do
  context "#validate" do
    context "existing vat number" do
      before do
        FakeWeb.register_uri(:get, "http://isvat.appspot.com/BE/0817331995/", :body => "true")
      end if $fakeweb
      
      it "returns true" do
        Valvat::Lookup.validate("BE0817331995").should eql(true)
      end
      
      it "allows Valvat instance as input" do
        Valvat::Lookup.validate(Valvat.new("BE0817331995")).should eql(true)
      end
    end
    
    context "not existing vat number" do
      before do
        FakeWeb.register_uri(:get, "http://isvat.appspot.com/BE/0817331995/", :body => "false")
      end if $fakeweb
      
      it "returns false" do
        Valvat::Lookup.validate("BE0817331995").should eql(false)
      end
    end
    
    context "invalid country code / input" do
      without_any_web_requests!
      
      it "returns false" do
        Valvat::Lookup.validate("AE259597697").should eql(false)
        Valvat::Lookup.validate("").should eql(false)
      end
    end
    
    context "country web service down" do
      before do
        json = "{\"error_message\": \"Member State service unavailable.\", \"error_code\": 1, \"error\": true}"
        FakeWeb.register_uri(:get, "http://isvat.appspot.com/DE/259597697/", :body => json)
      end if $fakeweb
      
      it "returns nil" do
        Valvat::Lookup.validate("DE259597697").should eql(nil)
      end
    end
  end
end