require 'spec_helper'

describe Valvat::Syntax do
  describe "#validate" do
    it "validates a DE vat number" do
      subject.validate("DE345889003").should eql(true)

      subject.validate("DE34588900").should eql(false)
      subject.validate("DE3458890090").should eql(false)
      subject.validate("DE34588900C").should eql(false)
    end

    it "validates a AT vat number" do
      subject.validate("ATU03458890").should eql(true)

      subject.validate("ATU034588908").should eql(false)
      subject.validate("ATU0345908").should eql(false)
      subject.validate("ATU0345889Y").should eql(false)
    end

    it "should validate BE vat number" do
      subject.validate("BE0817331995").should eql(true)

      subject.validate("BE081733199").should eql(false)
      subject.validate("BE08173319944").should eql(false)
      subject.validate("BE081733199H").should eql(false)
      subject.validate("BE1817331999").should eql(false)
    end

    it "validates a BG vat number" do
      subject.validate("BG468134789").should eql(true)
      subject.validate("BG4681347897").should eql(true)

      subject.validate("BG46813478979").should eql(false)
      subject.validate("BG4681347897C").should eql(false)
      subject.validate("BG46813478G").should eql(false)
      subject.validate("BG46813478").should eql(false)
    end

    it "validates a CY vat number" do
      subject.validate("CY36579347A").should eql(true)
      subject.validate("CY36579347C").should eql(true)

      subject.validate("CY36579347").should eql(false)
      subject.validate("CY365793478").should eql(false)
      subject.validate("CY365793478A").should eql(false)
      subject.validate("CY365793G").should eql(false)
    end

    it "validates a DK vat number" do
      subject.validate("DK67893463").should eql(true)

      subject.validate("DK678934637").should eql(false)
      subject.validate("DK6789346").should eql(false)
      subject.validate("DK6789346H").should eql(false)
    end

    it "validates a ES vat number" do
      subject.validate("ESX67345987").should eql(true)
      subject.validate("ESA6734598B").should eql(true)
      subject.validate("ES56734598C").should eql(true)

      subject.validate("ES167345987").should eql(false)
      subject.validate("ESX6734598").should eql(false)
      subject.validate("ESX673459890").should eql(false)
    end

    it "validates a EE vat number" do
      subject.validate("EE678678456").should eql(true)
      subject.validate("EE6786784560").should eql(false)
      subject.validate("EE67867845").should eql(false)
      subject.validate("EE67867845K").should eql(false)
    end

    it "validates a FI vat number" do
      subject.validate("FI67845638").should eql(true)

      subject.validate("FI678456389").should eql(false)
      subject.validate("FI6784563").should eql(false)
      subject.validate("FI6784563K").should eql(false)
    end

    it "validates a FR vat number" do
      subject.validate("FR99123543267").should eql(true)
      subject.validate("FRBB123543267").should eql(true)
      subject.validate("FR9B123543267").should eql(true)
      subject.validate("FRB9123543267").should eql(true)

      subject.validate("FR99123543267B").should eql(false)
      subject.validate("FRBB12354326").should eql(false)
      subject.validate("FR9B123543F67").should eql(false)
      subject.validate("FRB9123543").should eql(false)
    end

    it "validates a EL vat number" do
      subject.validate("EL678456345").should eql(true)

      subject.validate("EL67845634").should eql(false)
      subject.validate("EL6784563459").should eql(false)
      subject.validate("EL67845634P").should eql(false)
    end

    it "validates a HU vat number" do
      subject.validate("HU67894595").should eql(true)

      subject.validate("HU6789459").should eql(false)
      subject.validate("HU67894595L").should eql(false)
      subject.validate("HU6789459J").should eql(false)
    end

    it "validates a HR vat number" do
      subject.validate("HR12345678912").should eql(true)

      subject.validate("HR6789459").should eql(false)
      subject.validate("HR67894595L").should eql(false)
      subject.validate("HR6789459J").should eql(false)
    end

    it "validates a IE vat number" do
      subject.validate("IE1B12345J").should eql(true)
      subject.validate("IE1234567B").should eql(true)
      subject.validate("IE1234567XX").should eql(true)

      subject.validate("IE1B123459").should eql(false)
      subject.validate("IE19123450").should eql(false)
      subject.validate("IEA9123450").should eql(false)
      subject.validate("IE1B12345XX").should eql(false)
    end

    it "validates a IT vat number" do
      subject.validate("IT45875359285").should eql(true)

      subject.validate("IT458753592859").should eql(false)
      subject.validate("IT4587535928G").should eql(false)
      subject.validate("IT4587535928").should eql(false)
    end

    it "validates a LV vat number" do
      subject.validate("LV85678368906").should eql(true)

      subject.validate("LV8567836890").should eql(false)
      subject.validate("LV856783689066").should eql(false)
      subject.validate("LV8567836890S").should eql(false)
    end

    it "validates a LT vat number" do
      subject.validate("LT678678987").should eql(true)
      subject.validate("LT678678987956").should eql(true)

      subject.validate("LT67867898").should eql(false)
      subject.validate("LT6786789870").should eql(false)
      subject.validate("LT678678987K").should eql(false)
      subject.validate("LT67867898709").should eql(false)
      subject.validate("LT6786789870C").should eql(false)
      subject.validate("LT67867898795H").should eql(false)
    end

    it "validates a LU vat number" do
      subject.validate("LU45679456").should eql(true)

      subject.validate("LU4567945").should eql(false)
      subject.validate("LU456794560").should eql(false)
      subject.validate("LU4567945J").should eql(false)
    end

    it "validates a MT vat number" do
      subject.validate("MT64569367").should eql(true)

      subject.validate("MT6456936").should eql(false)
      subject.validate("MT645693679").should eql(false)
      subject.validate("MT6456936L").should eql(false)
    end

    it "validates a NL vat number" do
      subject.validate("NL673739491B77").should eql(true)

      subject.validate("NL673739491977").should eql(false)
      subject.validate("NL673739491A77").should eql(false)
      subject.validate("NL673739491B771").should eql(false)
      subject.validate("NL673739491B7").should eql(false)
      subject.validate("NL6737394917B7").should eql(false)
    end

    it "validates a PL vat number" do
      subject.validate("PL6784567284").should eql(true)

      subject.validate("PL678456728").should eql(false)
      subject.validate("PL67845672849").should eql(false)
      subject.validate("PL678456728K").should eql(false)
    end

    it "validates a PT vat number" do
      subject.validate("PT346296476").should eql(true)

      subject.validate("PT34629647").should eql(false)
      subject.validate("PT3462964769").should eql(false)
    end

    it "validates a GB vat number" do
      subject.validate("GB123456789").should eql(true)
      subject.validate("GB123456789012").should eql(true)
      subject.validate("GBGD123").should eql(true)
      subject.validate("GBHA123").should eql(true)

      subject.validate("GB12345678").should eql(false)
      subject.validate("GB1234567890").should eql(false)
      subject.validate("GB12345678901").should eql(false)
      subject.validate("GB1234567890123").should eql(false)
      subject.validate("GBAB123").should eql(false)
      subject.validate("GBAA123").should eql(false)
      subject.validate("GBHH123").should eql(false)
      subject.validate("GBGD1234").should eql(false)
      subject.validate("GBGD12").should eql(false)
    end

    it "validates a RO vat number" do
      subject.validate("RO1234567890").should eql(true)
      subject.validate("RO123456789").should eql(true)
      subject.validate("RO12345678").should eql(true)
      subject.validate("RO1234567").should eql(true)
      subject.validate("RO123456").should eql(true)
      subject.validate("RO12345").should eql(true)
      subject.validate("RO1234").should eql(true)
      subject.validate("RO123").should eql(true)
      subject.validate("RO12").should eql(true)

      subject.validate("RO1").should eql(false)
      subject.validate("RO0234567890").should eql(false)
      subject.validate("RO023456789").should eql(false)
      subject.validate("RO02345678").should eql(false)
      subject.validate("RO0234567").should eql(false)
      subject.validate("RO023456").should eql(false)
      subject.validate("RO02345").should eql(false)
      subject.validate("RO0234").should eql(false)
      subject.validate("RO023").should eql(false)
      subject.validate("RO02").should eql(false)
      subject.validate("RO12345678901").should eql(false)
    end

    it "validates a SK vat number" do
      subject.validate("SK5683075682").should eql(true)

      subject.validate("SK56830756821").should eql(false)
      subject.validate("SK568307568").should eql(false)
    end

    it "validates a SI vat number" do
      subject.validate("SI74357893").should eql(true)

      subject.validate("SI743578931").should eql(false)
      subject.validate("SI7435789").should eql(false)
    end

    it "validates a SE vat number" do
      subject.validate("SE567396352701").should eql(true)

      subject.validate("SE56739635201").should eql(false)
      subject.validate("SE5673963527701").should eql(false)
      subject.validate("SE567396352702").should eql(false)
      subject.validate("SE567396352711").should eql(false)
    end

    it "validates a CZ vat number" do
      subject.validate("CZ56389267").should eql(true)
      subject.validate("CZ563892670").should eql(true)
      subject.validate("CZ5638926790").should eql(true)

      subject.validate("CZ5638926").should eql(false)
      subject.validate("CZ56389268901").should eql(false)
    end

    it "returns false on blank/non-sense vat number" do
      subject.validate("").should eql(false)
      subject.validate(" ").should eql(false)
      subject.validate("DE").should eql(false)
      subject.validate("atu123xyz").should eql(false)
      subject.validate("xxxxxxxxxx").should eql(false)
      subject.validate("BEFR").should eql(false)
    end

    it "allows Valvat instance as input" do
      subject.validate(Valvat.new("DE345889003")).should eql(true)
      subject.validate(Valvat.new("DE34588900X")).should eql(false)
    end
  end
end
