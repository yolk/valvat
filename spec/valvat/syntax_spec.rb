require 'spec_helper'

describe Valvat::Syntax do
  context "#validate" do
    it "validates a DE vat number" do
      Valvat::Syntax.validate("DE345889003").should eql(true)
      
      Valvat::Syntax.validate("DE34588900").should eql(false)
      Valvat::Syntax.validate("DE3458890090").should eql(false)
      Valvat::Syntax.validate("DE34588900C").should eql(false)
    end

    it "validates a AT vat number" do
      Valvat::Syntax.validate("ATU03458890").should eql(true)
      
      Valvat::Syntax.validate("ATU034588908").should eql(false)
      Valvat::Syntax.validate("ATU0345908").should eql(false)
      Valvat::Syntax.validate("ATU0345889Y").should eql(false)
    end

    it "should validate BE vat number" do
      Valvat::Syntax.validate("BE0817331995").should eql(true)
      
      Valvat::Syntax.validate("BE081733199").should eql(false)
      Valvat::Syntax.validate("BE08173319944").should eql(false)
      Valvat::Syntax.validate("BE081733199H").should eql(false)
    end

    it "validates a BG vat number" do
      Valvat::Syntax.validate("BG468134789").should eql(true)
      Valvat::Syntax.validate("BG4681347897").should eql(true)

      Valvat::Syntax.validate("BG46813478979").should eql(false)
      Valvat::Syntax.validate("BG4681347897C").should eql(false)
      Valvat::Syntax.validate("BG46813478G").should eql(false)
      Valvat::Syntax.validate("BG46813478").should eql(false)
    end

    it "validates a CY vat number" do
      Valvat::Syntax.validate("CY36579347A").should eql(true)
      Valvat::Syntax.validate("CY36579347C").should eql(true)

      Valvat::Syntax.validate("CY36579347").should eql(false)
      Valvat::Syntax.validate("CY365793478").should eql(false)
      Valvat::Syntax.validate("CY365793478A").should eql(false)
      Valvat::Syntax.validate("CY365793G").should eql(false)
    end

    it "validates a DK vat number" do
      Valvat::Syntax.validate("DK67893463").should eql(true)

      Valvat::Syntax.validate("DK678934637").should eql(false)
      Valvat::Syntax.validate("DK6789346").should eql(false)
      Valvat::Syntax.validate("DK6789346H").should eql(false)
    end

    it "validates a ES vat number" do
      Valvat::Syntax.validate("ESX67345987").should eql(true)
      Valvat::Syntax.validate("ESA6734598B").should eql(true)
      Valvat::Syntax.validate("ES56734598C").should eql(true)

      Valvat::Syntax.validate("ES167345987").should eql(false)
      Valvat::Syntax.validate("ESX6734598").should eql(false)
      Valvat::Syntax.validate("ESX673459890").should eql(false)
    end

    it "validates a EE vat number" do
      Valvat::Syntax.validate("EE678678456").should eql(true)
      Valvat::Syntax.validate("EE6786784560").should eql(false)
      Valvat::Syntax.validate("EE67867845").should eql(false)
      Valvat::Syntax.validate("EE67867845K").should eql(false)
    end

    it "validates a FI vat number" do
      Valvat::Syntax.validate("FI67845638").should eql(true)

      Valvat::Syntax.validate("FI678456389").should eql(false)
      Valvat::Syntax.validate("FI6784563").should eql(false)
      Valvat::Syntax.validate("FI6784563K").should eql(false)
    end

    it "validates a FR vat number" do
      Valvat::Syntax.validate("FR99123543267").should eql(true)
      Valvat::Syntax.validate("FRBB123543267").should eql(true)
      Valvat::Syntax.validate("FR9B123543267").should eql(true)
      Valvat::Syntax.validate("FRB9123543267").should eql(true)

      Valvat::Syntax.validate("FR99123543267B").should eql(false)
      Valvat::Syntax.validate("FRBB12354326").should eql(false)
      Valvat::Syntax.validate("FR9B123543F67").should eql(false)
      Valvat::Syntax.validate("FRB9123543").should eql(false)
    end

    it "validates a EL vat number" do
      Valvat::Syntax.validate("EL678456345").should eql(true)

      Valvat::Syntax.validate("EL67845634").should eql(false)
      Valvat::Syntax.validate("EL6784563459").should eql(false)
      Valvat::Syntax.validate("EL67845634P").should eql(false)
    end

    it "validates a HU vat number" do
      Valvat::Syntax.validate("HU67894595").should eql(true)

      Valvat::Syntax.validate("HU6789459").should eql(false)
      Valvat::Syntax.validate("HU67894595L").should eql(false)
      Valvat::Syntax.validate("HU6789459J").should eql(false)
    end

    it "validates a IE vat number" do
      Valvat::Syntax.validate("IE1B12345J").should eql(true)
      Valvat::Syntax.validate("IE1234567B").should eql(true)

      Valvat::Syntax.validate("IE1B123459").should eql(false)
      Valvat::Syntax.validate("IE19123450").should eql(false)
      Valvat::Syntax.validate("IEA9123450").should eql(false)
    end

    it "validates a IT vat number" do
      Valvat::Syntax.validate("IT45875359285").should eql(true)

      Valvat::Syntax.validate("IT458753592859").should eql(false)
      Valvat::Syntax.validate("IT4587535928G").should eql(false)
      Valvat::Syntax.validate("IT4587535928").should eql(false)
    end

    it "validates a LV vat number" do
      Valvat::Syntax.validate("LV85678368906").should eql(true)

      Valvat::Syntax.validate("LV8567836890").should eql(false)
      Valvat::Syntax.validate("LV856783689066").should eql(false)
      Valvat::Syntax.validate("LV8567836890S").should eql(false)
    end

    it "validates a LT vat number" do
      Valvat::Syntax.validate("LT678678987").should eql(true)
      Valvat::Syntax.validate("LT678678987956").should eql(true)

      Valvat::Syntax.validate("LT67867898").should eql(false)
      Valvat::Syntax.validate("LT6786789870").should eql(false)
      Valvat::Syntax.validate("LT678678987K").should eql(false)
      Valvat::Syntax.validate("LT67867898709").should eql(false)
      Valvat::Syntax.validate("LT6786789870C").should eql(false)
      Valvat::Syntax.validate("LT67867898795H").should eql(false)
    end

    it "validates a LU vat number" do
      Valvat::Syntax.validate("LU45679456").should eql(true)

      Valvat::Syntax.validate("LU4567945").should eql(false)
      Valvat::Syntax.validate("LU456794560").should eql(false)
      Valvat::Syntax.validate("LU4567945J").should eql(false)
    end

    it "validates a MT vat number" do
      Valvat::Syntax.validate("MT64569367").should eql(true)

      Valvat::Syntax.validate("MT6456936").should eql(false)
      Valvat::Syntax.validate("MT645693679").should eql(false)
      Valvat::Syntax.validate("MT6456936L").should eql(false)
    end

    it "validates a NL vat number" do
      Valvat::Syntax.validate("NL673739491B77").should eql(true)

      Valvat::Syntax.validate("NL673739491977").should eql(false)
      Valvat::Syntax.validate("NL673739491A77").should eql(false)
      Valvat::Syntax.validate("NL673739491B771").should eql(false)
      Valvat::Syntax.validate("NL673739491B7").should eql(false)
      Valvat::Syntax.validate("NL6737394917B7").should eql(false)
    end

    it "validates a PL vat number" do
      Valvat::Syntax.validate("PL6784567284").should eql(true)

      Valvat::Syntax.validate("PL678456728").should eql(false)
      Valvat::Syntax.validate("PL67845672849").should eql(false)
      Valvat::Syntax.validate("PL678456728K").should eql(false)
    end

    it "validates a PT vat number" do
      Valvat::Syntax.validate("PT346296476").should eql(true)

      Valvat::Syntax.validate("PT34629647").should eql(false)
      Valvat::Syntax.validate("PT3462964769").should eql(false)
    end

    it "validates a GB vat number" do
      Valvat::Syntax.validate("GB123456789").should eql(true)
      Valvat::Syntax.validate("GB123456789012").should eql(true)
      Valvat::Syntax.validate("GBGD123").should eql(true)
      Valvat::Syntax.validate("GBHA123").should eql(true)

      Valvat::Syntax.validate("GB12345678").should eql(false)
      Valvat::Syntax.validate("GB1234567890").should eql(false)
      Valvat::Syntax.validate("GB12345678901").should eql(false)
      Valvat::Syntax.validate("GB1234567890123").should eql(false)
      Valvat::Syntax.validate("GBAB123").should eql(false)
      Valvat::Syntax.validate("GBAA123").should eql(false)
      Valvat::Syntax.validate("GBHH123").should eql(false)
      Valvat::Syntax.validate("GBGD1234").should eql(false)
      Valvat::Syntax.validate("GBGD12").should eql(false)
    end

    it "validates a RO vat number" do
      Valvat::Syntax.validate("RO1234567890").should eql(true)
      Valvat::Syntax.validate("RO123456789").should eql(true)
      Valvat::Syntax.validate("RO12345678").should eql(true)
      Valvat::Syntax.validate("RO1234567").should eql(true)
      Valvat::Syntax.validate("RO123456").should eql(true)
      Valvat::Syntax.validate("RO12345").should eql(true)
      Valvat::Syntax.validate("RO1234").should eql(true)
      Valvat::Syntax.validate("RO123").should eql(true)
      Valvat::Syntax.validate("RO12").should eql(true)

      Valvat::Syntax.validate("RO1").should eql(false)
      Valvat::Syntax.validate("RO0234567890").should eql(false)
      Valvat::Syntax.validate("RO023456789").should eql(false)
      Valvat::Syntax.validate("RO02345678").should eql(false)
      Valvat::Syntax.validate("RO0234567").should eql(false)
      Valvat::Syntax.validate("RO023456").should eql(false)
      Valvat::Syntax.validate("RO02345").should eql(false)
      Valvat::Syntax.validate("RO0234").should eql(false)
      Valvat::Syntax.validate("RO023").should eql(false)
      Valvat::Syntax.validate("RO02").should eql(false)
      Valvat::Syntax.validate("RO12345678901").should eql(false)
    end

    it "validates a SK vat number" do
      Valvat::Syntax.validate("SK5683075682").should eql(true)
      
      Valvat::Syntax.validate("SK56830756821").should eql(false)
      Valvat::Syntax.validate("SK568307568").should eql(false)
    end

    it "validates a SI vat number" do
      Valvat::Syntax.validate("SI74357893").should eql(true)
      
      Valvat::Syntax.validate("SI743578931").should eql(false)
      Valvat::Syntax.validate("SI7435789").should eql(false)
    end

    it "validates a SE vat number" do
      Valvat::Syntax.validate("SE567396352701").should eql(true)

      Valvat::Syntax.validate("SE56739635201").should eql(false)
      Valvat::Syntax.validate("SE5673963527701").should eql(false)
      Valvat::Syntax.validate("SE567396352702").should eql(false)
      Valvat::Syntax.validate("SE567396352711").should eql(false)
    end

    it "validates a CZ vat number" do
      Valvat::Syntax.validate("CZ56389267").should eql(true)
      Valvat::Syntax.validate("CZ563892670").should eql(true)
      Valvat::Syntax.validate("CZ5638926790").should eql(true)

      Valvat::Syntax.validate("CZ5638926").should eql(false)
      Valvat::Syntax.validate("CZ56389268901").should eql(false)
    end

    it "returns false on blank/non-sense vat number" do
      Valvat::Syntax.validate("").should eql(false)
      Valvat::Syntax.validate(" ").should eql(false)
      Valvat::Syntax.validate("DE").should eql(false)
      Valvat::Syntax.validate("atu123xyz").should eql(false)
      Valvat::Syntax.validate("xxxxxxxxxx").should eql(false)
      Valvat::Syntax.validate("BEFR").should eql(false)
    end
  
    it "allows Valvat instance as input" do
      Valvat::Syntax.validate(Valvat.new("DE345889003")).should eql(true)
      Valvat::Syntax.validate(Valvat.new("DE34588900X")).should eql(false)
    end
  end
end