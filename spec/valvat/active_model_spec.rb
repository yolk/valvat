require 'spec_helper'

class Invoice < ModelBase  
  validates :vat_number, :valvat => true
end

describe Invoice do
  context "with valid vat number" do
    before do
      Valvat::Syntax.stub(:validate => true)
    end
    
    it "should be valid" do
      Invoice.new(:vat_number => "DE345889003").should be_valid
    end
  end
  
  context "with invalid vat number" do
    before do
      Valvat::Syntax.stub(:validate => false)
    end
    
    it "should be valid" do
      Invoice.new(:vat_number => "DE345889003").should_not be_valid
    end
  end
end