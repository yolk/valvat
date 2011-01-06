require 'spec_helper'

describe Valvat::Lookup do
  context "#validate" do
    it "returns true on existing vat number" do
      Valvat::Lookup.validate("BE0817331995").should eql(true)
    end
    
    it "returns false on not existing vat number" do
      Valvat::Lookup.validate("BE0817331994").should eql(false)
    end
    
    it "returns false on invalid country code / input" do
      Valvat::Lookup.validate("AE259597697").should eql(false)
      Valvat::Lookup.validate("").should eql(false)
    end
  end
end