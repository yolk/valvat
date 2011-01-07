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

describe Invoice do
  context "with valid vat number" do
    before do
      Valvat::Syntax.stub(:validate => true)
    end
    
    it "should be valid" do
      Invoice.new(:vat_number => "DE123").should be_valid
    end
  end
  
  context "with invalid vat number" do
    before do
      Valvat::Syntax.stub(:validate => false)
    end
    
    it "should not be valid" do
      Invoice.new(:vat_number => "DE123").should_not be_valid
    end
    
    it "should add default (country specific) error message" do
      i = Invoice.new(:vat_number => "DE123")
      i.valid?
      i.errors[:vat_number].should eql(["is not a valid german vat number"])
    end
    
    context "with i18n translation in place" do
      before do
        I18n.backend.store_translations(:en, :activemodel => {
          :errors => {:models => {:invoice => {:invalid_vat => "is ugly."}}}
        })
      end
      
      after { I18n.reload! }
      
      it "should use translation" do
        i = Invoice.new(:vat_number => "DE123")
        i.valid?
        i.errors[:vat_number].should eql(["is ugly."])
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
        i = Invoice.new(:vat_number => "IE123")
        i.valid?
        i.errors[:vat_number].should eql(["is not a irish vat"])
      end

      it "should fall back to 'european' if country is missing" do
        i = Invoice.new(:vat_number => "XX123")
        i.valid?
        i.errors[:vat_number].should eql(["is not a european vat"])
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