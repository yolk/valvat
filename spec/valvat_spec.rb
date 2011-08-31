require 'spec_helper'

require 'spec_helper'

describe Valvat do
  context "#new" do
    it "demands one and only one argument" do
      lambda{ Valvat.new }.should raise_error(ArgumentError)
      lambda{ Valvat.new("a", "b") }.should raise_error(ArgumentError)
      lambda{ Valvat.new("a") }.should_not raise_error
    end
  end

  context "Valvat()" do
    it "initializes new Valvat instance on string" do
      Valvat("abc").should be_kind_of(Valvat)
    end

    it "returns same Valvat instance on Valvat instance" do
      vat = Valvat.new("abc")
      Valvat(vat).should be_kind_of(Valvat)
      Valvat(vat).object_id.should eql(vat.object_id)
    end
  end

  context "on european vat number" do
    let(:de_vat) { Valvat.new("DE259597697") } # valid & exists
    let(:at_vat) { Valvat.new("ATU458890031") } # invalid
    let(:gr_vat) { Valvat.new("EL999943280") } # valid & exists

    context "#valid?" do
      it "returns true on valid numbers" do
        de_vat.should be_valid
        gr_vat.should be_valid
      end

      it "returns false on invalid numbers" do
        at_vat.should_not be_valid
      end
    end

    context "#exist(s)?" do
      context "on existing vat numbers" do
        before do
          Valvat::Lookup.stub(:validate => true)
        end

        it "returns true" do
          de_vat.exists?.should eql(true)
          gr_vat.exists?.should eql(true)
          de_vat.exist?.should eql(true)
          gr_vat.exist?.should eql(true)
        end
      end

      context "on not existing vat numbers" do
        before do
          Valvat::Lookup.stub(:validate => false)
        end

        it "returns false" do
          at_vat.exists?.should eql(false)
          at_vat.exist?.should eql(false)
        end
      end
    end

    context "#iso_country_code" do
      it "returns iso country code on iso_country_code" do
        de_vat.iso_country_code.should eql("DE")
        at_vat.iso_country_code.should eql("AT")
      end

      it "returns GR iso country code on greek vat number" do
        gr_vat.iso_country_code.should eql("GR")
      end
    end

    context "#vat_country_code" do
      it "returns iso country code on iso_country_code" do
        de_vat.vat_country_code.should eql("DE")
        at_vat.vat_country_code.should eql("AT")
      end

      it "returns EL iso language code on greek vat number" do
        gr_vat.vat_country_code.should eql("EL")
      end
    end

    context "#european?" do
      it "returns true" do
        de_vat.should be_european
        at_vat.should be_european
        gr_vat.should be_european
      end
    end

    context "#to_s" do
      it "returns full vat number" do
        de_vat.to_s.should eql("DE259597697")
        at_vat.to_s.should eql("ATU458890031")
        gr_vat.to_s.should eql("EL999943280")
      end
    end

    context "#inspect" do
      it "returns vat number with iso country code" do
        de_vat.inspect.should eql("#<Valvat DE259597697 DE>")
        at_vat.inspect.should eql("#<Valvat ATU458890031 AT>")
        gr_vat.inspect.should eql("#<Valvat EL999943280 GR>")
      end
    end

    context "#to_a" do
      it "calls Valvat::Utils.split with raw vat number and returns result" do
        de_vat # initialize
        Valvat::Utils.should_receive(:split).once.with("DE259597697").and_return(["a", "b"])
        de_vat.to_a.should eql(["a", "b"])
      end
    end
  end

  context "on vat number from outside of europe" do
    let(:us_vat) { Valvat.new("US345889003") }
    let(:ch_vat) { Valvat.new("CH445889003") }

    context "#valid?" do
      it "returns false" do
        us_vat.should_not be_valid
        ch_vat.should_not be_valid
      end
    end

    context "#exist?" do
      without_any_web_requests!

      it "returns false" do
        us_vat.should_not be_exist
        ch_vat.should_not be_exist
      end
    end

    context "#iso_country_code" do
      it "returns nil" do
        us_vat.iso_country_code.should eql(nil)
        ch_vat.iso_country_code.should eql(nil)
      end
    end

    context "#vat_country_code" do
      it "returns nil" do
        us_vat.vat_country_code.should eql(nil)
        ch_vat.vat_country_code.should eql(nil)
      end
    end

    context "#european?" do
      it "returns false" do
        us_vat.should_not be_european
        ch_vat.should_not be_european
      end
    end

    context "#to_s" do
      it "returns full given vat number" do
        us_vat.to_s.should eql("US345889003")
        ch_vat.to_s.should eql("CH445889003")
      end
    end

    context "#inspect" do
      it "returns vat number without iso country code" do
        us_vat.inspect.should eql("#<Valvat US345889003>")
        ch_vat.inspect.should eql("#<Valvat CH445889003>")
      end
    end

  end

  context "on non-sense/empty vat number" do
    let(:only_iso_vat) { Valvat.new("DE") }
    let(:num_vat) { Valvat.new("12445889003") }
    let(:empty_vat) { Valvat.new("") }
    let(:nil_vat) { Valvat.new("") }

    context "#valid?" do
      it "returns false" do
        only_iso_vat.should_not be_valid
        num_vat.should_not be_valid
        empty_vat.should_not be_valid
        nil_vat.should_not be_valid
      end
    end

    context "#exist?" do
      without_any_web_requests!

      it "returns false" do
        only_iso_vat.should_not be_exist
        num_vat.should_not be_exist
        empty_vat.should_not be_exist
        nil_vat.should_not be_exist
      end
    end

    context "#iso_country_code" do
      it "returns nil" do
        only_iso_vat.iso_country_code.should eql(nil)
        num_vat.iso_country_code.should eql(nil)
        empty_vat.iso_country_code.should eql(nil)
        nil_vat.iso_country_code.should eql(nil)
      end
    end

    context "#vat_country_code" do
      it "returns nil" do
        only_iso_vat.vat_country_code.should eql(nil)
        num_vat.vat_country_code.should eql(nil)
        empty_vat.vat_country_code.should eql(nil)
        nil_vat.vat_country_code.should eql(nil)
      end
    end

    context "#european?" do
      it "returns false" do
        only_iso_vat.should_not be_european
        num_vat.should_not be_european
        empty_vat.should_not be_european
        nil_vat.should_not be_european
      end
    end

    context "#to_s" do
      it "returns full given vat number" do
        only_iso_vat.to_s.should eql("DE")
        num_vat.to_s.should eql("12445889003")
        empty_vat.to_s.should eql("")
        nil_vat.to_s.should eql("")
      end
    end

    context "#inspect" do
      it "returns vat number without iso country code" do
        only_iso_vat.inspect.should eql("#<Valvat DE>")
        num_vat.inspect.should eql("#<Valvat 12445889003>")
        empty_vat.inspect.should eql("#<Valvat >")
        nil_vat.inspect.should eql("#<Valvat >")
      end
    end

  end
end
