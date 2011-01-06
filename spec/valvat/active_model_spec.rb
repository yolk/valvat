require 'spec_helper'

class Invoice < ModelBase  
  validates :vat_number, :valvat => true
end

describe Invoice do
  it "validate with valid vat number" do
    Invoice.new(:vat_number => "DE345889003").should be_valid
  end
  
  it "not validate with invalid vat number" do
    Invoice.new(:vat_number => "DEX45889003").should_not be_valid
  end
end