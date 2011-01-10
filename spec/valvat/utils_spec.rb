require 'spec_helper'

describe Valvat::Utils do
  context "#split" do
    it "returns country and rest on vat number as array" do
      Valvat::Utils.split("DE345889003").should eql(["DE", "345889003"])
      Valvat::Utils.split("ESX4588900X").should eql(["ES", "X4588900X"])
    end
    
    it "returns two nils on non-european iso codes as array" do
      Valvat::Utils.split("US345889003").should eql([nil, nil])
      Valvat::Utils.split("RUX4588900X").should eql([nil, nil])
    end
    
    it "returns two nils on non-sense input as array" do
      Valvat::Utils.split("DE").should eql([nil, nil])
      Valvat::Utils.split("X345889003").should eql([nil, nil])
      Valvat::Utils.split("").should eql([nil, nil])
      Valvat::Utils.split("1234").should eql([nil, nil])
      Valvat::Utils.split(" ").should eql([nil, nil])
    end
    
    it "returns EL (language iso code) on greek vat" do
      Valvat::Utils.split("EL999999999").should eql(["EL", "999999999"])
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
    
    it "does not change already normalized vat numbers" do
      Valvat::Utils.normalize("DE345889003").should eql("DE345889003")
      Valvat::Utils.normalize("ESX4588900X").should eql("ESX4588900X")
    end
    
    it "removes spaces" do
      Valvat::Utils.normalize("DE 345889003").should eql("DE345889003")
      Valvat::Utils.normalize("ESX  458 8900 X").should eql("ESX4588900X")
    end
    
    it "removes special chars" do
      Valvat::Utils.normalize("DE.345-889_00:3,;").should eql("DE345889003")
    end
  end
  
  context "#vat_country_to_iso_country" do
    it "returns iso country code on greek iso language 'EL'" do
      Valvat::Utils.vat_country_to_iso_country("EL").should eql("GR")
    end
    
    Valvat::Utils::EU_COUNTRIES.each do |iso|
      it "returns unchanged iso country code '#{iso}'" do
        Valvat::Utils.vat_country_to_iso_country(iso).should eql(iso)
      end
    end
  end
end