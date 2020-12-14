# encoding: utf-8
require 'spec_helper'

describe Valvat::Utils do
  describe "#split" do
    it "returns country and rest on VAT number as array" do
      expect(Valvat::Utils.split("DE345889003")).to eql(["DE", "345889003"])
      expect(Valvat::Utils.split("ESX4588900X")).to eql(["ES", "X4588900X"])
    end

    it "returns two nils on non-european iso codes as array" do
      expect(Valvat::Utils.split("US345889003")).to eql([nil, nil])
      expect(Valvat::Utils.split("RUX4588900X")).to eql([nil, nil])
    end

    it "returns two nils on non-sense input as array" do
      expect(Valvat::Utils.split("DE")).to eql([nil, nil])
      expect(Valvat::Utils.split("X345889003")).to eql([nil, nil])
      expect(Valvat::Utils.split("")).to eql([nil, nil])
      expect(Valvat::Utils.split("1234")).to eql([nil, nil])
      expect(Valvat::Utils.split(" ")).to eql([nil, nil])
    end

    it "returns EL (language iso code) on greek vat" do
      expect(Valvat::Utils.split("EL999999999")).to eql(["EL", "999999999"])
    end
  end

  describe "#normalize" do
    it "returns VAT number with upcase chars" do
      expect(Valvat::Utils.normalize("de345889003")).to eql("DE345889003")
      expect(Valvat::Utils.normalize("EsX4588900y")).to eql("ESX4588900Y")
    end

    it "returns trimmed VAT number" do
      expect(Valvat::Utils.normalize(" DE345889003")).to eql("DE345889003")
      expect(Valvat::Utils.normalize("  DE345889003  ")).to eql("DE345889003")
      expect(Valvat::Utils.normalize("DE345889003 ")).to eql("DE345889003")
    end

    it "does not change already normalized VAT numbers" do
      expect(Valvat::Utils.normalize("DE345889003")).to eql("DE345889003")
      expect(Valvat::Utils.normalize("ESX4588900X")).to eql("ESX4588900X")
    end

    it "removes spaces" do
      expect(Valvat::Utils.normalize("DE 345889003")).to eql("DE345889003")
      expect(Valvat::Utils.normalize("ESX  458 8900 X")).to eql("ESX4588900X")
    end

    it "removes special chars" do
      expect(Valvat::Utils.normalize("DE.345-889_00:3,;")).to eql("DE345889003")
      expect(Valvat::Utils.normalize("→ DE·Ö34588 9003\0 ☺")).to eql("→DEÖ345889003☺")
    end
  end

  describe "#vat_country_to_iso_country" do
    it "returns iso country code on greek iso language 'EL'" do
      expect(Valvat::Utils.vat_country_to_iso_country("EL")).to eql("GR")
    end

    Valvat::Utils::EU_MEMBER_STATES.each do |iso|
      it "returns unchanged iso country code '#{iso}'" do
        expect(Valvat::Utils.vat_country_to_iso_country(iso)).to eql(iso)
      end
    end
  end

  describe "#iso_country_to_vat_country" do
    it "returns VAT country on greek iso country code 'GR'" do
      expect(Valvat::Utils.iso_country_to_vat_country("GR")).to eql("EL")
    end

    Valvat::Utils::EU_MEMBER_STATES.each do |c|
      it "returns unchanged VAT country code '#{c}'" do
        expect(Valvat::Utils.iso_country_to_vat_country(c)).to eql(c)
      end unless c == "GR"
    end
  end

  describe "#country_is_supported?" do
    Valvat::Utils::EU_MEMBER_STATES.each do |code|
      it "returns true on #{code}" do
        expect(Valvat::Utils.country_is_supported?(code)).to eql(true)
      end
    end

    it "returns true on GB" do
      expect(Valvat::Utils.country_is_supported?("GB")).to eql(true)
    end

    ["US", "AE", "CA", "CN", "BR", "AU", "NO", "ML"].each do |code|
      it "returns false on #{code}" do
        expect(Valvat::Utils.country_is_supported?(code)).to eql(false)
      end
    end
  end
end
