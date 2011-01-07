## valvat

Validates european vat numbers. Standalone or as a ActiveModel validator.

### Features

* Simple syntax verification
* Lookup via the VIES web service
* Works standalone without any gem dependencies
* (Optional) ActiveModel/Rails3 integration
* I18n locales for country specific error messages

valvat is tested and works with ruby 1.8.7/1.9.2 and ActiveModel 3.0.

### Installation

  gem install valvat

### Basic Usage

To verify the syntax of a vat number:

  Valvat::Syntax.validate("DE345789003")
  => true or false
  
To check if the given vat number exists:

  Valvat::Lookup.validate("DE345789003")
  => true or false or nil
  
Keep in mind that the VIES webservice might be offline at some time for some countries. If this happens Valvat::Lookup.validate returns nil.

See http://ec.europa.eu/taxation_customs/vies/viesspec.do for more accurate information at what time the service for a specific country will be down.

### ActiveModel/Rails3 Usage

When the valvat gem is required and ActiveModel is already loaded, everything will work fine out of the box. If your load order differs just add

  require 'valvat/active_model'
  
after ActiveModel has been loaded.
  
To validate the attribute _vat_number_ add this to your model:

  class MyModel < ActiveRecord::Base
    validates :vat_number, :valvat => true
  end
  
To additionally perform a lookup via VIES:

  validates :vat_number, :valvat => {:lookup => true}
  
By default this will validate to true if the VIES web service is down. To fail in this case simply add the _:fail_if_down_ option:

  validates :vat_number, :valvat => {:lookup => :fail_if_down}
  
By default blank vat numbers validate to false, to change this add the _:allow_blank_ option:

  validates :vat_number, :valvat => {:allow_blank => true}

### Utilities

To split a vat number into the ISO country code and the remaining chars:

  Valvat::Utils.split("ATU345789003")
  => ["AT", "U345789003"]
  
_split_ always returns an array. If it can not detect the country it returns [nil, nil].

To normalize a vat number:

  Valvat::Utils.normalize("atu345789003")
  => "ATU345789003"
  
This basically just removes trailing spaces and ensures all chars are upcase.

### Links

* http://ec.europa.eu/taxation_customs/vies
* http://bzst.de/DE/Steuern_International/USt_Identifikationsnummer/Merkblaetter/Aufbau_USt_IdNr.html (german)
* http://en.wikipedia.org/wiki/European_Union_Value_Added_Tax
* http://isvat.appspot.com/

### BlaBla

Copyright (c) 2011 Yolk Sebastian Munz & Julia Soergel GbR

Beyond that, the implementation is licensed under the MIT License.