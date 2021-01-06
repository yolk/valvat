# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Syntax do
  describe '#validate' do
    it 'validates a DE VAT number' do
      expect(described_class.validate('DE345889003')).to be(true)

      expect(described_class.validate('DE34588900')).to be(false)
      expect(described_class.validate('DE3458890090')).to be(false)
      expect(described_class.validate('DE34588900C')).to be(false)
    end

    it 'validates a AT VAT number' do
      expect(described_class.validate('ATU03458890')).to be(true)

      expect(described_class.validate('ATU034588908')).to be(false)
      expect(described_class.validate('ATU0345908')).to be(false)
      expect(described_class.validate('ATU0345889Y')).to be(false)
    end

    it 'validates BE VAT number' do
      expect(described_class.validate('BE0817331995')).to be(true)

      expect(described_class.validate('BE081733199')).to be(false)
      expect(described_class.validate('BE08173319944')).to be(false)
      expect(described_class.validate('BE081733199H')).to be(false)
      expect(described_class.validate('BE1817331999')).to be(false)
    end

    it 'validates a BG VAT number' do
      expect(described_class.validate('BG468134789')).to be(true)
      expect(described_class.validate('BG4681347897')).to be(true)

      expect(described_class.validate('BG46813478979')).to be(false)
      expect(described_class.validate('BG4681347897C')).to be(false)
      expect(described_class.validate('BG46813478G')).to be(false)
      expect(described_class.validate('BG46813478')).to be(false)
    end

    it 'validates a CY VAT number' do
      expect(described_class.validate('CY36579347A')).to be(true)
      expect(described_class.validate('CY36579347C')).to be(true)

      expect(described_class.validate('CY36579347')).to be(false)
      expect(described_class.validate('CY365793478')).to be(false)
      expect(described_class.validate('CY365793478A')).to be(false)
      expect(described_class.validate('CY365793G')).to be(false)
    end

    it 'validates a DK VAT number' do
      expect(described_class.validate('DK67893463')).to be(true)

      expect(described_class.validate('DK678934637')).to be(false)
      expect(described_class.validate('DK6789346')).to be(false)
      expect(described_class.validate('DK6789346H')).to be(false)
    end

    it 'validates a ES VAT number' do
      expect(described_class.validate('ESX67345987')).to be(true)
      expect(described_class.validate('ESA6734598B')).to be(true)
      expect(described_class.validate('ES56734598C')).to be(true)

      expect(described_class.validate('ES167345987')).to be(false)
      expect(described_class.validate('ESX6734598')).to be(false)
      expect(described_class.validate('ESX673459890')).to be(false)
    end

    it 'validates a EE VAT number' do
      expect(described_class.validate('EE100207415')).to be(true)
      expect(described_class.validate('EE1002074150')).to be(false)
      expect(described_class.validate('EE10020741')).to be(false)
      expect(described_class.validate('EE100207415K')).to be(false)
    end

    it 'validates a FI VAT number' do
      expect(described_class.validate('FI67845638')).to be(true)

      expect(described_class.validate('FI678456389')).to be(false)
      expect(described_class.validate('FI6784563')).to be(false)
      expect(described_class.validate('FI6784563K')).to be(false)
    end

    it 'validates a FR VAT number' do
      expect(described_class.validate('FR99123543267')).to be(true)
      expect(described_class.validate('FRBB123543267')).to be(true)
      expect(described_class.validate('FR9B123543267')).to be(true)
      expect(described_class.validate('FRB9123543267')).to be(true)

      expect(described_class.validate('FR99123543267B')).to be(false)
      expect(described_class.validate('FRBB12354326')).to be(false)
      expect(described_class.validate('FR9B123543F67')).to be(false)
      expect(described_class.validate('FRB9123543')).to be(false)
    end

    it 'validates a EL VAT number' do
      expect(described_class.validate('EL678456345')).to be(true)

      expect(described_class.validate('EL67845634')).to be(false)
      expect(described_class.validate('EL6784563459')).to be(false)
      expect(described_class.validate('EL67845634P')).to be(false)
    end

    it 'validates a HU VAT number' do
      expect(described_class.validate('HU67894595')).to be(true)

      expect(described_class.validate('HU6789459')).to be(false)
      expect(described_class.validate('HU67894595L')).to be(false)
      expect(described_class.validate('HU6789459J')).to be(false)
    end

    it 'validates a HR VAT number' do
      expect(described_class.validate('HR12345678912')).to be(true)

      expect(described_class.validate('HR6789459')).to be(false)
      expect(described_class.validate('HR67894595L')).to be(false)
      expect(described_class.validate('HR6789459J')).to be(false)
    end

    it 'validates a IE VAT number' do
      expect(described_class.validate('IE1B12345J')).to be(true)
      expect(described_class.validate('IE1234567B')).to be(true)
      expect(described_class.validate('IE1234567XX')).to be(true)

      expect(described_class.validate('IE1B123459')).to be(false)
      expect(described_class.validate('IE19123450')).to be(false)
      expect(described_class.validate('IEA9123450')).to be(false)
      expect(described_class.validate('IE1B12345XX')).to be(false)
      expect(described_class.validate('IE1X34567XX')).to be(false)
    end

    it 'validates a IT VAT number' do
      expect(described_class.validate('IT45875359285')).to be(true)

      expect(described_class.validate('IT458753592859')).to be(false)
      expect(described_class.validate('IT4587535928G')).to be(false)
      expect(described_class.validate('IT4587535928')).to be(false)
    end

    it 'validates a LV VAT number' do
      expect(described_class.validate('LV85678368906')).to be(true)

      expect(described_class.validate('LV8567836890')).to be(false)
      expect(described_class.validate('LV856783689066')).to be(false)
      expect(described_class.validate('LV8567836890S')).to be(false)
    end

    it 'validates a LT VAT number' do
      expect(described_class.validate('LT213179412')).to be(true)
      expect(described_class.validate('LT290061371314')).to be(true)

      expect(described_class.validate('LT21317942')).to be(false)
      expect(described_class.validate('LT213179422')).to be(false)
      expect(described_class.validate('LT2131794120')).to be(false)
      expect(described_class.validate('LT213179412K')).to be(false)
      expect(described_class.validate('LT29006137132')).to be(false)
      expect(described_class.validate('LT290061371324')).to be(false)
      expect(described_class.validate('LT29006137131C')).to be(false)
      expect(described_class.validate('LT290061371314H')).to be(false)
    end

    it 'validates a LU VAT number' do
      expect(described_class.validate('LU45679456')).to be(true)

      expect(described_class.validate('LU4567945')).to be(false)
      expect(described_class.validate('LU456794560')).to be(false)
      expect(described_class.validate('LU4567945J')).to be(false)
    end

    it 'validates a MT VAT number' do
      expect(described_class.validate('MT64569367')).to be(true)

      expect(described_class.validate('MT6456936')).to be(false)
      expect(described_class.validate('MT645693679')).to be(false)
      expect(described_class.validate('MT6456936L')).to be(false)
    end

    it 'validates a NL VAT number' do
      expect(described_class.validate('NL673739491B77')).to be(true)

      expect(described_class.validate('NL673739491977')).to be(false)
      expect(described_class.validate('NL673739491A77')).to be(false)
      expect(described_class.validate('NL673739491B771')).to be(false)
      expect(described_class.validate('NL673739491B7')).to be(false)
      expect(described_class.validate('NL6737394917B7')).to be(false)
    end

    it 'validates a PL VAT number' do
      expect(described_class.validate('PL6784567284')).to be(true)

      expect(described_class.validate('PL678456728')).to be(false)
      expect(described_class.validate('PL67845672849')).to be(false)
      expect(described_class.validate('PL678456728K')).to be(false)
    end

    it 'validates a PT VAT number' do
      expect(described_class.validate('PT346296476')).to be(true)

      expect(described_class.validate('PT34629647')).to be(false)
      expect(described_class.validate('PT3462964769')).to be(false)
    end

    it 'validates a GB VAT number' do
      expect(described_class.validate('GB123456789')).to be(true)
      expect(described_class.validate('GB123456789012')).to be(true)
      expect(described_class.validate('GBGD123')).to be(true)
      expect(described_class.validate('GBHA123')).to be(true)

      expect(described_class.validate('GB12345678')).to be(false)
      expect(described_class.validate('GB1234567890')).to be(false)
      expect(described_class.validate('GB12345678901')).to be(false)
      expect(described_class.validate('GB1234567890123')).to be(false)
      expect(described_class.validate('GBAB123')).to be(false)
      expect(described_class.validate('GBAA123')).to be(false)
      expect(described_class.validate('GBHH123')).to be(false)
      expect(described_class.validate('GBGD1234')).to be(false)
      expect(described_class.validate('GBGD12')).to be(false)
    end

    it 'validates a RO VAT number' do
      expect(described_class.validate('RO1234567890')).to be(true)
      expect(described_class.validate('RO123456789')).to be(true)
      expect(described_class.validate('RO12345678')).to be(true)
      expect(described_class.validate('RO1234567')).to be(true)
      expect(described_class.validate('RO123456')).to be(true)
      expect(described_class.validate('RO12345')).to be(true)
      expect(described_class.validate('RO1234')).to be(true)
      expect(described_class.validate('RO123')).to be(true)
      expect(described_class.validate('RO12')).to be(true)

      expect(described_class.validate('RO1')).to be(false)
      expect(described_class.validate('RO0234567890')).to be(false)
      expect(described_class.validate('RO023456789')).to be(false)
      expect(described_class.validate('RO02345678')).to be(false)
      expect(described_class.validate('RO0234567')).to be(false)
      expect(described_class.validate('RO023456')).to be(false)
      expect(described_class.validate('RO02345')).to be(false)
      expect(described_class.validate('RO0234')).to be(false)
      expect(described_class.validate('RO023')).to be(false)
      expect(described_class.validate('RO02')).to be(false)
      expect(described_class.validate('RO12345678901')).to be(false)
    end

    it 'validates a SK VAT number' do
      expect(described_class.validate('SK5683075682')).to be(true)

      expect(described_class.validate('SK56830756821')).to be(false)
      expect(described_class.validate('SK568307568')).to be(false)
    end

    it 'validates a SI VAT number' do
      expect(described_class.validate('SI74357893')).to be(true)

      expect(described_class.validate('SI743578931')).to be(false)
      expect(described_class.validate('SI7435789')).to be(false)
    end

    it 'validates a SE VAT number' do
      expect(described_class.validate('SE567396352701')).to be(true)

      expect(described_class.validate('SE56739635201')).to be(false)
      expect(described_class.validate('SE5673963527701')).to be(false)
      expect(described_class.validate('SE567396352702')).to be(false)
      expect(described_class.validate('SE567396352711')).to be(false)
    end

    it 'validates a CZ VAT number' do
      expect(described_class.validate('CZ56389267')).to be(true)
      expect(described_class.validate('CZ563892670')).to be(true)
      expect(described_class.validate('CZ5638926790')).to be(true)

      expect(described_class.validate('CZ5638926')).to be(false)
      expect(described_class.validate('CZ56389268901')).to be(false)
    end

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
