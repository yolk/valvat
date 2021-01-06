# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Checksum::PT do
  %w[PT136695973 PT501413197 PT503037753 PT500243590 PT500100144 PT502921838].each do |valid_vat|
    it "returns true on valid VAT #{valid_vat}" do
      expect(Valvat::Checksum.validate(valid_vat)).to be(true)
    end

    invalid_vat = "#{valid_vat[0..-5]}#{valid_vat[-1]}#{valid_vat[-4]}#{valid_vat[-2]}#{valid_vat[-3]}"

    it "returns false on invalid VAT #{invalid_vat}" do
      expect(Valvat::Checksum.validate(invalid_vat)).to be(false)
    end
  end

  # Portuguese business VAT should start with the following numbers
  # 1 or 2 (pessoa singular)                             - singular person
  # 5 (pessoa colectiva)                                 - collective person
  # 6 (pessoa colectiva publica)                         - public collective person
  # 8 (empresario em nome individual)                    - individual enterpreneur
  # 9 (pessoa colectiva irregular ou numero provisorio)  - provisional number
  # http://www.nif.pt/nif-das-empresas/
  %w[PT148166644 PT111623448 PT204874866 PT292261314 PT579104222 PT628910002 PT812627318 PT943935784].each do |number|
    it "returns true on a valid number - #{number}" do
      expect(Valvat::Checksum.validate(number)).to be(true)
    end
  end
end
