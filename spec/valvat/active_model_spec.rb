require 'spec_helper'

class Invoice < ModelBase
  validates :vat_number, :valvat => true
end

class InvoiceWithLookup < ModelBase
  validates :vat_number, :valvat => {:lookup => true}
end

class InvoiceWithLookupAndFailIfDown < ModelBase
  validates :vat_number, :valvat => {:lookup => :fail_if_down}
end

class InvoiceAllowBlank < ModelBase
  validates :vat_number, :valvat => {:allow_blank => true}
end

class InvoiceAllowBlankOnAll < ModelBase
  validates :vat_number, :valvat => true, :allow_blank => true
end

class InvoiceCheckCountry < ModelBase
  validates :vat_number, :valvat => {:match_country => :country}

  def country
    @attributes[:country]
  end
end

class InvoiceCheckCountryWithLookup < ModelBase
  validates :vat_number, :valvat => {:match_country => :country, :lookup => true}

  def country
    @attributes[:country]
  end
end

class InvoiceWithChecksum < ModelBase
  validates :vat_number, :valvat => {:checksum => true}
end

describe Invoice do
  context "with valid vat number" do
    it "should be valid" do
      Invoice.new(:vat_number => "DE259597697").should be_valid
    end
  end

  context "with invalid vat number" do
    let(:invoice) { Invoice.new(:vat_number => "DE259597697123") }

    it "should not be valid" do
      invoice.should_not be_valid
    end

    it "should add default (country specific) error message" do
      invoice.valid?
      invoice.errors[:vat_number].should eql(["is not a valid German vat number"])
    end

    context "with i18n translation in place" do
      before do
        I18n.backend.store_translations(:en, :activemodel => {
          :errors => {:models => {:invoice => {:invalid_vat => "is ugly."}}}
        })
      end

      after { I18n.reload! }

      it "should use translation" do
        invoice.valid?
        invoice.errors[:vat_number].should eql(["is ugly."])
      end
    end

    context "with i18n translation with country adjective placeholder in place" do
      before do
        I18n.backend.store_translations(:en, :activemodel => {
          :errors => {:models => {:invoice => {:invalid_vat => "is not a %{country_adjective} vat"}}}
        })
      end

      after { I18n.reload! }

      it "should replace country adjective placeholder" do
        invoice = Invoice.new(:vat_number => "IE123")
        invoice.valid?
        invoice.errors[:vat_number].should eql(["is not a Irish vat"])
      end

      it "should fall back to 'European' if country is missing" do
        invoice = Invoice.new(:vat_number => "XX123")
        invoice.valid?
        invoice.errors[:vat_number].should eql(["is not a European vat"])
      end
    end
  end

  context "with blank vat number" do
    it "should not be valid" do
      Invoice.new(:vat_number => "").should_not be_valid
      Invoice.new(:vat_number => nil).should_not be_valid
    end
  end
end

describe InvoiceWithLookup do
  context "with valid but not existing vat number" do
    before do
      Valvat::Syntax.stub(:validate => true)
      Valvat::Lookup.stub(:validate => false)
    end

    it "should not be valid" do
      InvoiceWithLookup.new(:vat_number => "DE123").should_not be_valid
    end
  end

  context "with valid and existing vat number" do
    before do
      Valvat::Syntax.stub(:validate => true)
      Valvat::Lookup.stub(:validate => true)
    end

    it "should be valid" do
      InvoiceWithLookup.new(:vat_number => "DE123").should be_valid
    end
  end

  context "with valid vat number and VIES country service down" do
    before do
      Valvat::Syntax.stub(:validate => true)
      Valvat::Lookup.stub(:validate => nil)
    end

    it "should be valid" do
      InvoiceWithLookup.new(:vat_number => "DE123").should be_valid
    end
  end
end

describe InvoiceWithLookupAndFailIfDown do
  context "with valid vat number and VIES country service down" do
    before do
      Valvat::Syntax.stub(:validate => true)
      Valvat::Lookup.stub(:validate => nil)
    end

    it "should not be valid" do
      InvoiceWithLookupAndFailIfDown.new(:vat_number => "DE123").should_not be_valid
    end
  end
end

describe InvoiceAllowBlank do
  context "with blank vat number" do
    it "should be valid" do
      InvoiceAllowBlank.new(:vat_number => "").should be_valid
      InvoiceAllowBlank.new(:vat_number => nil).should be_valid
    end
  end
end

describe InvoiceAllowBlankOnAll do
  context "with blank vat number" do
    it "should be valid" do
      InvoiceAllowBlankOnAll.new(:vat_number => "").should be_valid
      InvoiceAllowBlankOnAll.new(:vat_number => nil).should be_valid
    end
  end
end

describe InvoiceCheckCountry do
  it "should be not valid on blank country" do
    InvoiceCheckCountry.new(:country => nil, :vat_number => "DE259597697").should_not be_valid
    InvoiceCheckCountry.new(:country => "", :vat_number => "DE259597697").should_not be_valid
  end

  it "should be not valid on wired country" do
    InvoiceCheckCountry.new(:country => "XAXXX", :vat_number => "DE259597697").should_not be_valid
    InvoiceCheckCountry.new(:country => "ZO", :vat_number => "DE259597697").should_not be_valid
  end

  it "should be not valid on mismatching (eu) country" do
    InvoiceCheckCountry.new(:country => "FR", :vat_number => "DE259597697").should_not be_valid
    InvoiceCheckCountry.new(:country => "AT", :vat_number => "DE259597697").should_not be_valid
    InvoiceCheckCountry.new(:country => "DE", :vat_number => "ATU65931334").should_not be_valid
  end

  it "should be valid on matching country" do
    InvoiceCheckCountry.new(:country => "DE", :vat_number => "DE259597697").should be_valid
    InvoiceCheckCountry.new(:country => "AT", :vat_number => "ATU65931334").should be_valid
  end

  it "should give back error message with country from :country_match" do
    invoice = InvoiceCheckCountry.new(:country => "FR", :vat_number => "DE259597697")
    invoice.valid?
    invoice.errors[:vat_number].should eql(["is not a valid French vat number"])
  end

  it "should give back error message with country from :country_match even on invalid vat number" do
    invoice = InvoiceCheckCountry.new(:country => "FR", :vat_number => "DE259597697123")
    invoice.valid?
    invoice.errors[:vat_number].should eql(["is not a valid French vat number"])
  end
end

describe InvoiceCheckCountryWithLookup do
  before do
    Valvat::Syntax.stub(:validate => true)
    Valvat::Lookup.stub(:validate => true)
  end

  it "avoids lookup or syntax check on failed because of mismatching country" do
    Valvat::Syntax.should_not_receive(:validate)
    Valvat::Lookup.should_not_receive(:validate)
    InvoiceCheckCountryWithLookup.new(:country => "FR", :vat_number => "DE259597697").valid?
  end

  it "check syntax and looup on matching country" do
    Valvat::Syntax.should_receive(:validate).and_return(true)
    Valvat::Lookup.should_receive(:validate).and_return(true)
    InvoiceCheckCountryWithLookup.new(:country => "DE", :vat_number => "DE259597697").valid?
  end
end

describe InvoiceWithChecksum do
  context "with valid vat number" do
    it "should be valid" do
      InvoiceWithChecksum.new(:vat_number => "DE259597697").should be_valid
    end
  end

  context "with invalid vat number" do
    it "should not be valid" do
      InvoiceWithChecksum.new(:vat_number => "DE259597687").should_not be_valid
    end
  end
end