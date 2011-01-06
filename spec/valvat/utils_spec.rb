require 'spec_helper'

describe Valvat::Utils do
  context "#split" do
    it "returns country and rest on vat number as array" do
      Valvat::Utils.split("DE345889003").should eql(["DE", "345889003"])
      Valvat::Utils.split("XY345889003").should eql(["XY", "345889003"])
    end
    
    it "returns two nils on non-sense input as array" do
      Valvat::Utils.split("DE").should eql([nil, nil])
      Valvat::Utils.split("X345889003").should eql([nil, nil])
      Valvat::Utils.split("").should eql([nil, nil])
      Valvat::Utils.split("1234").should eql([nil, nil])
      Valvat::Utils.split(" ").should eql([nil, nil])
    end
  end
  
  context "#normalize" do
    it "returns vat number with upcase chars" do
      Valvat::Utils.normalize("de345889003").should eql("DE345889003")
      Valvat::Utils.normalize("EsX4588900y").should eql("ESX4588900Y")
    end
    
    it "returns trimmed vat number" do
      Valvat::Utils.normalize(" DE345889003").should eql("DE345889003")
      Valvat::Utils.normalize("  DE345889003  ").should eql("DE345889003")
      Valvat::Utils.normalize("DE345889003 ").should eql("DE345889003")
    end
    
    it "dors not change already normalized vat numbers" do
      Valvat::Utils.normalize("DE345889003").should eql("DE345889003")
      Valvat::Utils.normalize("ESX4588900X").should eql("ESX4588900X")
    end
  end
end