== valvat

Validates european vat numbers. Supports simple syntax verification and lookup via the VIES web service.

== Installation

  gem install valvat

== Basic Usage

To verify the syntax of an vat number:

  Valvat::Syntax.validate("DE345789003")
  => true or false
  
To check if the given vat number exists:

  Valvat::Lookup.validate("DE345789003")
  => true or false or nil
  
Keep in mind that the VIES webservice might be offline at some time for some countries. If this happens Valvat::Lookup.validate returns nil.

See http://ec.europa.eu/taxation_customs/vies/viesspec.do for more accurate information at what time the service for a specific country will be down.

== Links

* http://ec.europa.eu/taxation_customs/vies
* http://www.bzst.de/DE/Steuern_International/USt_Identifikationsnummer/Merkblaetter/Aufbau_USt_IdNr.html (german)
* http://en.wikipedia.org/wiki/European_Union_Value_Added_Tax

== BlaBla

Copyright (c) 2011 Yolk Sebastian Munz & Julia Soergel GbR