# valvat

Validates european vat numbers. Standalone or as a ActiveModel validator.

## Features

* Simple syntax verification
* Lookup via the VIES web service
* (Optional) ActiveModel/Rails3 integration
* Works standalone without ActiveModel
* I18n locales for country specific error messages

valvat is tested and works with ruby 1.8.7/1.9.2 and ActiveModel 3.0.

## Installation

    gem install valvat

## Basic Usage

To verify the syntax of a vat number:

    Valvat.new("DE345789003").valid?
    => true or false
  
To check if the given vat number exists via the VIES web service:

    Valvat.new("DE345789003").exists?
    => true or false or nil
  
Keep in mind that the VIES web service might be offline at some time for some countries. If this happens `Valvat::Lookup.validate` returns `nil`.

Visit [http://ec.europa.eu/taxation_customs/vies/viesspec.do](http://ec.europa.eu/taxation_customs/vies/viesspec.do) for more accurate information at what time the service for a specific country will be down.

It is also possible to bypass initializing a Valvat instance and check the syntax of a var number string directly with:

    Valvat::Syntax.validate("DE345789003")
    => true or false
  
Or to lookup a vat number string directly via VIES web service:

    Valvat::Lookup.validate("DE345789003")
    => true or false or nil
    
If you need all details and not only if the VAT is valid, pass true as second parameter to the lookup call.

   Valvat::Lookup.validate("IE6388047V",true)
   => {:country_code=>"IE", :vat_number=>"6388047V", :request_date=>#<Date: 2012-05-05 ((2456053j,0s,0n),+0s,2299161j)>, :valid=>true, :name=>"GOOGLE IRELAND LIMITED", :address=>"1ST & 2ND FLOOR ,GORDON HOUSE ,BARROW STREET ,DUBLIN 4", :@xmlns=>"urn:ec.europa.eu:taxud:vies:services:checkVat:types"}

According to EU law, or at least as Austria sees it, it's mandatory to verify the UID number of every new customer, but also to check the UID Number periodicaly. To prove that you have checked the UID number, the VIES Web service can return a requestIdentifier.
To receive a requestIdentifier you need to pass your own VAT number and the VAT number you want to check. 
In this Example, Google (VAT IE6388047V) is checking the validity of eBays VAT number (LU21416127)

   Valvat::Lookup.validate_with_id("LU21416127","IE6388047V")
   => {:country_code=>"LU", :vat_number=>"21416127", :request_date=>#<Date: 2012-05-05 ((2456053j,0s,0n),+0s,2299161j)>, :valid=>true, :trader_name=>"EBAY EUROPE S.A R.L.", :trader_company_type=>"---", :trader_address=>"22, BOULEVARD ROYAL\nL-2449  LUXEMBOURG", :request_identifier=>"WAPIAAAATcdf80jt", :@xmlns=>"urn:ec.europa.eu:taxud:vies:services:checkVat:types"}

## ActiveModel/Rails3 Usage

### Loading

When the valvat gem is required and ActiveModel is already loaded, everything will work fine out of the box. If your load order differs just add

    require 'valvat/active_model'
  
after ActiveModel has been loaded.

### Simple syntax validation
  
To validate the attribute `vat_number` add this to your model:

    class MyModel < ActiveRecord::Base
      validates :vat_number, :valvat => true
    end

### Additional lookup validation
  
To additionally perform a lookup via VIES:

    validates :vat_number, :valvat => {:lookup => true}
  
By default this will validate to true if the VIES web service is down. To fail in this case simply add the `:fail_if_down` option:

    validates :vat_number, :valvat => {:lookup => :fail_if_down}

### Additional ISO country code validation

If you want the vat number’s (ISO) country to match another country attribute, use the _match_country_ option: 

    validates :vat_number, :valvat => {:match_country => :country}

where it is supposed that your model has a method named _country_ which returns the country ISO code you want to match.

### Allow blank

By default blank vat numbers validate to false. To change this add the `:allow_blank` option:

    validates :vat_number, :valvat => {:allow_blank => true}

### Allow vat numbers outside of europe
  
To allow vat numbers from outside of europe, add something like this to your model (country_code should return a upcase ISO country code):

    class MyModel < ActiveRecord::Base
      validates :vat_number, :valvat => true, :if => :eu?
      
      def eu?
        Valvat::Utils::EU_COUNTRIES.include?(country_code)
      end
    end
    
## Utilities

To split a vat number into the country code and the remaining chars:

    Valvat::Utils.split("ATU345789003")
    => ["AT", "U345789003"]
    
or

    Valvat.new("ATU345789003").to_a
    => ["AT", "U345789003"]
  
Both methods always return an array. If it can not detect the country or the given country is located outside of europe it returns `[nil, nil]`. Please note that this does not strictly return the ISO country code: for greek vat numbers this returns the ISO language code 'EL' instead of the ISO country code 'GR'.

To extract the ISO country code of a given vat number:

    Valvat.new("EL7345789003").iso_country_code
    => "GR"
  
To extract the vat country code (first two chars in every european vat number):

    Valvat.new("EL7345789003").vat_country_code
    => "EL"

To normalize a vat number:

    Valvat::Utils.normalize("atu345789003")
    => "ATU345789003"
  
This basically just removes trailing spaces and ensures all chars are uppercase.

## Links

* [VIES web service](http://ec.europa.eu/taxation_customs/vies)
* [European vat number formats (german)](http://bzst.de/DE/Steuern_International/USt_Identifikationsnummer/Merkblaetter/Aufbau_USt_IdNr.html)
* [European vat number formats on Wikipedia](http://en.wikipedia.org/wiki/European_Union_Value_Added_Tax)

## BlaBla

Copyright (c) 2011 Yolk Sebastian Munz & Julia Soergel GbR

Beyond that, the implementation is licensed under the MIT License.