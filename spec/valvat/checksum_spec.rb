require 'spec_helper'

describe Valvat::Checksum do
  describe "#validate" do
    it "returns true on vat number with unknown checksum algorithm" do
      Valvat::Checksum.validate("FR99123543267").should eql(true)
    end
  end
end