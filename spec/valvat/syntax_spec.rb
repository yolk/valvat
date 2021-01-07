# frozen_string_literal: true

require 'spec_helper'

def it_validates(valid_vats, invalid_vats)
  valid_vats.each do |valid|
    it "returns true for #{valid.inspect}" do
      expect(described_class.validate(valid)).to be(true)
    end
  end

  invalid_vats.each do |invalid|
    it "returns false for #{invalid.inspect}" do
      expect(described_class.validate(invalid)).to be(false)
    end
  end
end

describe Valvat::Syntax do
  describe '#validate' do
    it_validates(%w[ATU03458890], %w[ATU034588908 ATU0345908 ATU0345889Y])
    it_validates(%w[BE0817331995], %w[BE081733199 BE08173319944 BE081733199H BE1817331999])
    it_validates(%w[BG468134789 BG4681347897], %w[BG46813478979 BG4681347897C BG46813478G BG46813478])
    it_validates(%w[CY36579347A CY36579347C], %w[CY36579347 CY365793478 CY365793478A CY365793G])
    it_validates(%w[CZ56389267 CZ563892670 CZ5638926790], %w[CZ5638926 CZ56389268901])
    it_validates(%w[DE345889003], %w[DE34588900 DE3458890090 DE34588900C])
    it_validates(%w[DK67893463], %w[DK678934637 DK6789346 DK6789346H])
    it_validates(%w[EE100207415], %w[EE1002074150 EE10020741 EE10020741 EE100207415K])
    it_validates(%w[EL678456345], %w[EL67845634 EL6784563459 EL67845634P])
    it_validates(%w[ESX67345987 ESA6734598B ES56734598C], %w[ES167345987 ESX6734598 ESX673459890])
    it_validates(%w[FI67845638], %w[FI678456389 FI6784563 FI6784563K])
    it_validates(%w[FR99123543267 FRBB123543267 FR9B123543267 FRB9123543267],
                 %w[FR99123543267B FRBB12354326 FR9B123543F67 FRB9123543])
    it_validates(%w[GB123456789 GB123456789012 GBGD123 GBHA123],
                 %w[GB12345678 GB1234567890 GB12345678901 GB1234567890123 GBAB123 GBAA123 GBHH123 GBGD1234 GBGD12])
    it_validates(%w[HR12345678912], %w[HR6789459 HR67894595L HR6789459J])
    it_validates(%w[HU67894595], %w[HU6789459 HU67894595L HU6789459J])
    it_validates(%w[IE1B12345J IE1234567B IE1234567XX], %w[IE1B123459 IE19123450 IEA9123450 IE1B12345XX IE1X34567XX])
    it_validates(%w[IT45875359285], %w[IT458753592859 IT4587535928G IT4587535928])
    it_validates(%w[LT213179412 LT290061371314],
                 %w[LT21317942 LT213179422 LT2131794120 LT213179412K LT29006137132 LT290061371324 LT29006137131C
                    LT290061371314H])
    it_validates(%w[LU45679456], %w[LU4567945 LU456794560 LU4567945J])
    it_validates(%w[LV85678368906], %w[LV8567836890 LV856783689066 LV8567836890S])
    it_validates(%w[MT64569367], %w[MT6456936 MT645693679 MT6456936L])
    it_validates(%w[NL673739491B77], %w[NL673739491977 NL673739491A77 NL673739491B771 NL673739491B7 NL6737394917B7])
    it_validates(%w[PL6784567284], %w[PL678456728 PL67845672849 PL678456728K])
    it_validates(%w[PT346296476], %w[PT34629647 PT3462964769])
    it_validates(%w[RO1234567890 RO123456789 RO12345678 RO1234567 RO123456 RO12345 RO1234 RO123 RO12],
                 %w[RO1 RO0234567890 RO023456789 RO02345678 RO0234567 RO023456 RO02345 RO0234 RO02 RO12345678901])
    it_validates(%w[SE567396352701], %w[SE56739635201 SE5673963527701 SE567396352702 SE567396352711])
    it_validates(%w[SI74357893], %w[SI743578931 SI7435789])
    it_validates(%w[SK5683075682], %w[SK56830756821 SK568307568])
    it_validates(%w[XI123456789 XI123456789012 XIGD123 XIHA123],
                 %w[XI12345678 XI12345678901234 XIGD1234 XIHA1234 XIGD12 XIHA12 XIHD123])

    it 'returns false on blank/non-sense VAT number' do
      ['', ' ', 'DE', 'atu123xyz', 'xxxxxxxxxx', 'BEFR'].each do |input|
        expect(described_class.validate(input)).to be(false)
      end
    end

    it 'allows Valvat instance as input' do
      expect(described_class.validate(Valvat.new('DE345889003'))).to be(true)
      expect(described_class.validate(Valvat.new('DE34588900X'))).to be(false)
    end
  end
end
