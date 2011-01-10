### dev

[full changelog](http://github.com/yolk/valvat/compare/v0.2.2...master)

### 0.2.2 / 2011-01-10

[full changelog](http://github.com/yolk/valvat/compare/v0.2.1...v0.2.2)

* Using vies directly via soap/savon again; isvat.appspot.com is not _really_ reliable.
* Added support for Valvat#exist? as an alias of Valvat#exists?

### 0.2.1 / 2011-01-07

[full changelog](http://github.com/yolk/valvat/compare/v0.2.0...v0.2.1)

* Fixed blocker in valvat/lookup

### 0.2.0 / 2011-01-07

[full changelog](http://github.com/yolk/valvat/compare/v0.1.1...v0.2.0)

* Rewrote Valvat module to a vat number class for convenience + internal use of Valvat instances
* I18n: Default error messages in german

### 0.1.1 / 2011-01-07

[full changelog](http://github.com/yolk/valvat/compare/v0.1.0...v0.1.1)

* Fixed issue with country web service down and added spec
* Stubbed web service specs with fakeweb
* Added documentation for ActiveModel support

### 0.1.0 / 2011-01-07

[full changelog](http://github.com/yolk/valvat/compare/v0.0.3...v0.1.0)

* ActiveModel validation: added optional lookup support
* ActiveModel validation: I18n support with country specific messages
* ActiveModel validation: I18n locales in english and german
* Fixed bug with wrong iso country code on greek vat number (EL != GR)
* Valvat::Util.split only returns countries from europe

### 0.0.3 / 2011-01-06

[full changelog](http://github.com/yolk/valvat/compare/v0.0.2...v0.0.3)

* Basic support for ActiveModel validation

### 0.0.2 / 2011-01-06

[full changelog](http://github.com/yolk/valvat/compare/v0.0.1...v0.0.2)

* Use REST-wrapper for accessing VIES web service; this removes dependency on savon and some lines of code. See http://isvat.appspot.com/