require 'spec_helper'

describe Valvat::Lookup::Request do
  it "returns Response on success" do
    response = Valvat::Lookup::Request.new("IE6388047V", {}).perform
    expect(response).to be_a(Valvat::Lookup::Response)
    expect(response.to_hash[:name]).to eql("GOOGLE IRELAND LIMITED")
  end

  it "returns Fault on failure" do
    response = Valvat::Lookup::Request.new("XC123123", {}).perform
    expect(response).to be_a(Valvat::Lookup::Fault)
    expect(response.to_hash).to eql({valid: false})
  end
end