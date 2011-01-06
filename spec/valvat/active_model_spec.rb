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
    
    it "should be valid" do
      Invoice.new(:vat_number => "DE123").should_not be_valid
    end
  end
end

describe InvoiceWithLookup do
  context "with valid but not existing vat number" do
    before do
      Valvat::Syntax.stub(:validate => true)
      Valvat::Lookup.stub(:validate => false)
    end
    
    it "should be valid" do
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
  
  context "with valid and VIES country service down" do
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
  context "with valid and VIES country service down" do
    before do
      Valvat::Syntax.stub(:validate => true)
      Valvat::Lookup.stub(:validate => nil)
    end
    
    it "should be valid" do
      InvoiceWithLookupAndFailIfDown.new(:vat_number => "DE123").should_not be_valid
    end
  end
end