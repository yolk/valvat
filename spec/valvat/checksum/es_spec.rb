require 'spec_helper'

describe Valvat::Checksum::ES do
  %w(ESA13585625 ESB83871236 ESE54507058 ES25139013J ESQ1518001A ESQ5018001G ESX4942978W ESX7676464F ESB10317980).each do |valid_vat|
    it "returns true on valid vat #{valid_vat}" do
      Valvat::Checksum.validate(valid_vat).should eql(true)
    end

    invalid_vat = "#{valid_vat[0..-6]}#{valid_vat[-2]}#{valid_vat[-5]}#{valid_vat[-4]}#{valid_vat[-3]}#{valid_vat[-1]}"

    it "returns false on invalid vat #{invalid_vat}" do
      Valvat::Checksum.validate(invalid_vat).should eql(false)
    end
  end
end