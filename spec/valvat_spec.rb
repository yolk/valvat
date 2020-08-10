require 'spec_helper'

require 'spec_helper'

describe Valvat do
  describe "#new" do
    it "demands one and only one argument" do
      expect{ Valvat.new }.to raise_error(ArgumentError)
      expect{ Valvat.new("a", "b") }.to raise_error(ArgumentError)
      expect{ Valvat.new("a") }.not_to raise_error
    end

    it "normalizes input string" do
      expect(Valvat.new("de25.9597,69 7").to_s).to eql("DE259597697")
      expect(Valvat.new("de25.9597,69 7").iso_country_code).to eql("DE")
    end
  end

  context "Valvat()" do
    it "initializes new Valvat instance on string" do
      expect(Valvat("abc")).to be_kind_of(Valvat)
    end

    it "returns same Valvat instance on Valvat instance" do
      vat = Valvat.new("abc")
      expect(Valvat(vat)).to be_kind_of(Valvat)
      expect(Valvat(vat).object_id).to eql(vat.object_id)
    end
  end


  describe "#blank?" do

    it "returns true when when initialized with nil" do
      expect(Valvat.new(nil)).to be_blank
    end

    it "returns true when when initialized with an empty string" do
      expect(Valvat.new(" ")).to be_blank
    end

    it "returns false when initialized with a value" do
      expect(Valvat.new("DE259597697")).not_to be_blank
    end
  end

  context "on european VAT number" do
    let(:de_vat) { Valvat.new("DE259597697") } # valid & exists
    let(:invalid_checksum) { Valvat.new("DE259597687") } # valid & invalid checksum
    let(:at_vat) { Valvat.new("ATU458890031") } # invalid
    let(:gr_vat) { Valvat.new("EL999943280") } # valid & exists

    describe "#valid?" do
      it "returns true on valid numbers" do
        expect(de_vat).to be_valid
        expect(gr_vat).to be_valid
      end

      it "returns false on invalid numbers" do
        expect(at_vat).not_to be_valid
      end
    end

    describe "#valid_checksum?" do
      it "returns true on valid numbers" do
        expect(de_vat).to be_valid_checksum
        expect(gr_vat).to be_valid_checksum
      end

      it "returns false on invalid numbers" do
        expect(at_vat).not_to be_valid_checksum
        expect(invalid_checksum).not_to be_valid_checksum
      end
    end

    describe "#exist(s)?" do
      context "on existing VAT numbers" do
        before do
          allow(Valvat::Lookup).to receive_messages(validate: true)
        end

        it "returns true" do
          expect(de_vat.exists?).to eql(true)
          expect(gr_vat.exists?).to eql(true)
          expect(de_vat.exist?).to eql(true)
          expect(gr_vat.exist?).to eql(true)
        end
      end

      context "on not existing VAT numbers" do
        before do
          allow(Valvat::Lookup).to receive_messages(validate: false)
        end

        it "returns false" do
          expect(at_vat.exists?).to eql(false)
          expect(at_vat.exist?).to eql(false)
        end
      end

      context "with options" do
        it "calls Valvat::Lookup.validate with options" do
          expect(Valvat::Lookup).to receive(:validate).once.with(de_vat, detail: true, bla: 'blupp').and_return(true)
          expect(de_vat.exists?(detail: true, bla: 'blupp')).to eql(true)
        end
      end
    end

    describe "#iso_country_code" do
      it "returns iso country code on iso_country_code" do
        expect(de_vat.iso_country_code).to eql("DE")
        expect(at_vat.iso_country_code).to eql("AT")
      end

      it "returns GR iso country code on greek VAT number" do
        expect(gr_vat.iso_country_code).to eql("GR")
      end
    end

    describe "#vat_country_code" do
      it "returns iso country code on iso_country_code" do
        expect(de_vat.vat_country_code).to eql("DE")
        expect(at_vat.vat_country_code).to eql("AT")
      end

      it "returns EL iso language code on greek VAT number" do
        expect(gr_vat.vat_country_code).to eql("EL")
      end
    end

    describe "#european?" do
      it "returns true" do
        expect(de_vat).to be_european
        expect(at_vat).to be_european
        expect(gr_vat).to be_european
      end
    end

    describe "#to_s" do
      it "returns full VAT number" do
        expect(de_vat.to_s).to eql("DE259597697")
        expect(at_vat.to_s).to eql("ATU458890031")
        expect(gr_vat.to_s).to eql("EL999943280")
      end
    end

    describe "#inspect" do
      it "returns VAT number with iso country code" do
        expect(de_vat.inspect).to eql("#<Valvat DE259597697 DE>")
        expect(at_vat.inspect).to eql("#<Valvat ATU458890031 AT>")
        expect(gr_vat.inspect).to eql("#<Valvat EL999943280 GR>")
      end
    end

    describe "#to_a" do
      it "calls Valvat::Utils.split with raw VAT number and returns result" do
        de_vat # initialize
        expect(Valvat::Utils).to receive(:split).once.with("DE259597697").and_return(["a", "b"])
        expect(de_vat.to_a).to eql(["a", "b"])
      end
    end
  end

  context "on VAT number from outside of europe" do
    let(:us_vat) { Valvat.new("US345889003") }
    let(:ch_vat) { Valvat.new("CH445889003") }

    describe "#valid?" do
      it "returns false" do
        expect(us_vat).not_to be_valid
        expect(ch_vat).not_to be_valid
      end
    end

    describe "#exist?" do
      it "returns false" do
        expect(us_vat).not_to be_exist
        expect(ch_vat).not_to be_exist
      end
    end

    describe "#iso_country_code" do
      it "returns nil" do
        expect(us_vat.iso_country_code).to eql(nil)
        expect(ch_vat.iso_country_code).to eql(nil)
      end
    end

    describe "#vat_country_code" do
      it "returns nil" do
        expect(us_vat.vat_country_code).to eql(nil)
        expect(ch_vat.vat_country_code).to eql(nil)
      end
    end

    describe "#european?" do
      it "returns false" do
        expect(us_vat).not_to be_european
        expect(ch_vat).not_to be_european
      end
    end

    describe "#to_s" do
      it "returns full given VAT number" do
        expect(us_vat.to_s).to eql("US345889003")
        expect(ch_vat.to_s).to eql("CH445889003")
      end
    end

    describe "#inspect" do
      it "returns VAT number without iso country code" do
        expect(us_vat.inspect).to eql("#<Valvat US345889003>")
        expect(ch_vat.inspect).to eql("#<Valvat CH445889003>")
      end
    end

  end

  context "on non-sense/empty VAT number" do
    let(:only_iso_vat) { Valvat.new("DE") }
    let(:num_vat) { Valvat.new("12445889003") }
    let(:empty_vat) { Valvat.new("") }
    let(:nil_vat) { Valvat.new("") }

    describe "#valid?" do
      it "returns false" do
        expect(only_iso_vat).not_to be_valid
        expect(num_vat).not_to be_valid
        expect(empty_vat).not_to be_valid
        expect(nil_vat).not_to be_valid
      end
    end

    describe "#exist?" do
      it "returns false" do
        expect(only_iso_vat).not_to be_exist
        expect(num_vat).not_to be_exist
        expect(empty_vat).not_to be_exist
        expect(nil_vat).not_to be_exist
      end
    end

    describe "#iso_country_code" do
      it "returns nil" do
        expect(only_iso_vat.iso_country_code).to eql(nil)
        expect(num_vat.iso_country_code).to eql(nil)
        expect(empty_vat.iso_country_code).to eql(nil)
        expect(nil_vat.iso_country_code).to eql(nil)
      end
    end

    describe "#vat_country_code" do
      it "returns nil" do
        expect(only_iso_vat.vat_country_code).to eql(nil)
        expect(num_vat.vat_country_code).to eql(nil)
        expect(empty_vat.vat_country_code).to eql(nil)
        expect(nil_vat.vat_country_code).to eql(nil)
      end
    end

    describe "#european?" do
      it "returns false" do
        expect(only_iso_vat).not_to be_european
        expect(num_vat).not_to be_european
        expect(empty_vat).not_to be_european
        expect(nil_vat).not_to be_european
      end
    end

    describe "#to_s" do
      it "returns full given VAT number" do
        expect(only_iso_vat.to_s).to eql("DE")
        expect(num_vat.to_s).to eql("12445889003")
        expect(empty_vat.to_s).to eql("")
        expect(nil_vat.to_s).to eql("")
      end
    end

    describe "#inspect" do
      it "returns VAT number without iso country code" do
        expect(only_iso_vat.inspect).to eql("#<Valvat DE>")
        expect(num_vat.inspect).to eql("#<Valvat 12445889003>")
        expect(empty_vat.inspect).to eql("#<Valvat >")
        expect(nil_vat.inspect).to eql("#<Valvat >")
      end
    end

  end
end