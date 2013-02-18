require 'spec_helper'

describe Valvat::Checksum do
  describe "#validate" do
    context "validates DE" do
      %w(DE280857971 DE281381706 DE283108332 DE813622378 DE813628528 DE814178359 DE811907980).each do |valid_vat|
        it "returns true on valid vat #{valid_vat}" do
          subject.validate(valid_vat).should eql(true)
        end

        invalid_vat = "#{valid_vat[0..-3]}#{valid_vat[-1]}#{valid_vat[-2]}"

        it "returns false on invalid vat #{invalid_vat} #{valid_vat}" do
          subject.validate(invalid_vat).should eql(false)
        end
      end
    end

    context "validates BE" do
      %w(BE123456749 BE136695962 BE0817331995).each do |valid_vat|
        it "returns true on valid vat #{valid_vat}" do
          subject.validate(valid_vat).should eql(true)
        end

        invalid_vat = "#{valid_vat[0..-3]}#{valid_vat[-1]}#{valid_vat[-2]}"

        it "returns false on invalid vat #{invalid_vat} #{valid_vat}" do
          subject.validate(invalid_vat).should eql(false)
        end
      end
    end

    context "validates DK" do
      %w(DK13585628 DK61126228).each do |valid_vat|
        it "returns true on valid vat #{valid_vat}" do
          subject.validate(valid_vat).should eql(true)
        end

        invalid_vat = "#{valid_vat[0..-3]}#{valid_vat[-1]}#{valid_vat[-2]}"

        it "returns false on invalid vat #{invalid_vat} #{valid_vat}" do
          subject.validate(invalid_vat).should eql(false)
        end
      end
    end
  end
end