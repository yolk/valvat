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

    context "validates FI" do
      %w(FI13669598 FI20584306 FI01080233).each do |valid_vat|
        it "returns true on valid vat #{valid_vat}" do
          subject.validate(valid_vat).should eql(true)
        end

        invalid_vat = "#{valid_vat[0..-4]}#{valid_vat[-1]}#{valid_vat[-2]}#{valid_vat[-3]}"

        it "returns false on invalid vat #{invalid_vat} #{valid_vat}" do
          subject.validate(invalid_vat).should eql(false)
        end
      end
    end

    context "validates GR" do
      %w(EL123456783 EL094543092 EL998219694).each do |valid_vat|
        it "returns true on valid vat #{valid_vat}" do
          subject.validate(valid_vat).should eql(true)
        end

        invalid_vat = "#{valid_vat[0..-3]}#{valid_vat[-1]}#{valid_vat[-2]}"

        it "returns false on invalid vat #{invalid_vat} #{valid_vat}" do
          subject.validate(invalid_vat).should eql(false)
        end
      end
    end

    context "validates IE" do
      %w(IE8473625E IE0123459N IE9B12345N).each do |valid_vat|
        it "returns true on valid vat #{valid_vat}" do
          subject.validate(valid_vat).should eql(true)
        end

        invalid_vat = "#{valid_vat[0..-4]}#{valid_vat[-2]}#{valid_vat[-3]}#{valid_vat[-1]}"

        it "returns false on invalid vat #{invalid_vat} #{valid_vat}" do
          subject.validate(invalid_vat).should eql(false)
        end
      end
    end

    context "validates IT" do
      %w(IT12345670785 IT01897810162 IT00197200132).each do |valid_vat|
        it "returns true on valid vat #{valid_vat}" do
          subject.validate(valid_vat).should eql(true)
        end

        invalid_vat = "#{valid_vat[0..-3]}#{valid_vat[-1]}#{valid_vat[-2]}"

        it "returns false on invalid vat #{invalid_vat} #{valid_vat}" do
          subject.validate(invalid_vat).should eql(false)
        end
      end

      it "returns false on invalid special case vat IT12345671783" do
        subject.validate("IT12345671783").should eql(false)
      end

      it "returns false on invalid special case vat IT00000000133" do
        subject.validate("IT00000000133").should eql(false)
      end
    end

    context "validates LU" do
      %w(LU13669580 LU25361352 LU23124018 LU17560609).each do |valid_vat|
        it "returns true on valid vat #{valid_vat}" do
          subject.validate(valid_vat).should eql(true)
        end

        invalid_vat = "#{valid_vat[0..-4]}#{valid_vat[-2]}#{valid_vat[-3]}#{valid_vat[-1]}"

        it "returns false on invalid vat #{invalid_vat} #{valid_vat}" do
          subject.validate(invalid_vat).should eql(false)
        end
      end
    end

    context "validates NL" do
      %w(NL123456782B12 NL802549391B01 NL808661863B01 NL820893559B01).each do |valid_vat|
        it "returns true on valid vat #{valid_vat}" do
          subject.validate(valid_vat).should eql(true)
        end

        invalid_vat = "#{valid_vat[0..-5]}#{valid_vat[-2]}#{valid_vat[-3]}#{valid_vat[-4]}#{valid_vat[-1]}"

        it "returns false on invalid vat #{invalid_vat} #{valid_vat}" do
          subject.validate(invalid_vat).should eql(false)
        end
      end
    end
  end
end