
### dev

[full changelog](http://github.com/yolk/valvat/compare/v2.0.1...master)

### 2.0.1 / 2024-19-06

[full changelog](http://github.com/yolk/valvat/compare/v.2.0.0...v2.0.1)

* Valvat::Options#check_uk_key: Fixed missing silence variable
* Added vies_down translation for italian locale [Lorenzo Zabot](https://github.com/Uaitt)

### 2.0.0 / 2024-12-06

[full changelog](http://github.com/yolk/valvat/compare/v.1.4.4...v2.0.0)

BREAKING CHANGE: To validate UK VAT numbers you have to provide authentication credentials for the HMRC API. From valvat v2 onwards, simply setting the `:uk` option to `true` will always return `false` (same as the default).

* Added support for HMRC API v2.0 with OAuth 2.0 authentication [Denys Metelov](https://github.com/Skumring)
* Resolved the rexml security vulnerabilities that affected versions < 3.3.6 by [Riana Ferreira](https://github.com/bad-vegan)

### 1.4.4 / 2024-07-11

[full changelog](http://github.com/yolk/valvat/compare/v1.4.3...v1.4.4)

* Merged missed pull request intended for v1.4.3: Readded translation files back to the gem [Edouard Brière](https://github.com/edouard)

### 1.4.3 / 2024-07-11

[full changelog](http://github.com/yolk/valvat/compare/v1.4.2...v1.4.3)

* Missed to merge pull request. Skip this version.

### 1.4.2 / 2024-07-09

[full changelog](http://github.com/yolk/valvat/compare/v1.4.1...v1.4.2)

* Resolved [rexml security vulnerability](https://github.com/ruby/rexml/security/advisories/GHSA-vg3r-rm7w-2xgh) by [Riana Ferreira](https://github.com/bad-vegan)

### 1.4.1 / 2024-01-08

[full changelog](http://github.com/yolk/valvat/compare/v1.4.0...v1.4.1)

* Fixed incorrect variable usage in SOAP request body by [Jay Tabudlo](https://github.com/jaymoneybird))

### 1.4.0 / 2023-07-20

[full changelog](http://github.com/yolk/valvat/compare/v1.3.0...v1.4.0)

* Valvat.configure: Allow global configuration
* Update the Cyprus syntax regular expression by [Orien Madgwick](https://github.com/orien))
* Valvat::Checksum::ES: Fixed issue with VAT ids starting with '*00' #124 / #115 (by [Thomas Scalise](https://github.com/KirtashW17))

### 1.3.0 / 2023-04-19

[full changelog](http://github.com/yolk/valvat/compare/v1.2.1...v1.3.0)

* Checksum::FR: Correct validation for french VAT ids not starting with two numerical chars #119
* Equality for Valvat objects #120

### 1.2.1 / 2022-10-05

[full changelog](http://github.com/yolk/valvat/compare/v1.2.0...v1.2.1)

* Added missing dependency rexml #117
* Lookup: Retry IOError
* Lookup: require 'date' in VIES and 'time' in HMRC

### 1.2.0 / 2022-09-30

[full changelog](http://github.com/yolk/valvat/compare/v1.1.5...v1.2.0)

* Implemented lookup of VAT numbers from the UK (via HMRC api and only with :uk option set to true) (by [Adrien Rey-Jarthon](https://github.com/jarthod))
* Remimplemented VIES lookup using only nethttp (removes dependency on savon)
* Deprecate require 'valvat/local'. Please require 'valvat' directly.
* Apply more rules to spanish VAT numbers on checksum validation #115 (by [Thomas Scalise](https://github.com/KirtashW17))

### 1.1.5 / 2022-09-14

[full changelog](http://github.com/yolk/valvat/compare/v1.1.4...v1.1.5)

* Fixed natural person VAT checksum validation for ES #114 (by [Thomas Scalise](https://github.com/KirtashW17))
* Better (ruby) code blocks in README #113
* Minor internal syntax changes / refactorings

### 1.1.4 / 2022-05-05

[full changelog](http://github.com/yolk/valvat/compare/v1.1.3...v1.1.4)

* Support BE 1-series format (by [Cashaca](https://github.com/Cashaca))
* Removed duplication on french error messages (by [Sunny Ripert](https://github.com/sunny))

### 1.1.3 / 2022-01-26

[full changelog](http://github.com/yolk/valvat/compare/v1.1.2...v1.1.3)

* Handle Savon::HTTPError and Savon::UnknownOperationError as LookupError and throw Valvat::HTTPError and Valvat::OperationUnknown instead.

### 1.1.2 / 2021-10-29

[full changelog](http://github.com/yolk/valvat/compare/v1.1.1...v1.1.2)

* Fixed SOAPAction error (#105) (by [Ľubo ](https://github.com/lubosch))

### 1.1.1 / 2021-07-15

[full changelog](http://github.com/yolk/valvat/compare/v1.1.0...v1.1.1)

* Added support for italian VAT numbers with special province part (#104)

### 1.1.0 / 2021-01-15

[full changelog](http://github.com/yolk/valvat/compare/v1.0.1...v1.1.0)

* Added support for Northern Ireland XI prefixed VAT numbers (by [Avatar Ignacy Kasperowicz](https://github.com/kspe))
* ActiveModel: Return specific error message if VIES is down and fail_if_down is set to true (by [Arkadiy Zabazhanov](https://github.com/pyromaniac))
* Removed support for EOL rubies (all before 2.5) and ActiveModel before 5.0

### 1.0.1 / 2020-12-06

[full changelog](http://github.com/yolk/valvat/compare/v1.0.0...v1.0.1)

* Added missing spaces to malformatted portuegese locale file
* Removed GB from EU_COUNTRIES / EU_MEMBER_STATES but kept support
* Fixed typo in error message: UNK(N)OWN (by [Igor Gonchar](https://github.com/gigorok))

### 1.0.0 / 2020-11-06

[full changelog](http://github.com/yolk/valvat/compare/v0.9.1...v1.0.0)

* Refactored lookup to use specific rescue for savons soapfaults
* Raises vies specific error classes to help debugging temporary and permanent VIES errors
* Lookup#validate supports :savon option to allow altering the behaviour of the used savon client
* ActiveModel validator now supports all lookup options.
* Use https instead of http for accessing vies (by [Crazy Chris](https://github.com/lubekpl))
* Lookup#validate supports :raise_error option to return nil instead of raising (known) error when connecting to the VIES web service.
* [BUGFIX] Checksum: Prevent error on some invalid IE vat numbers
* EN: Capitalized VAT in error messages (and specs) (by [Vitalii Kashoid](https://github.com/Kashoid23))

### 0.9.1 / 2020-03-19

[full changelog](http://github.com/yolk/valvat/compare/v0.9.0...v0.9.1)

* Follow redirects to fix alteration of VIES-API (by [xxswingxx](https://github.com/xxswingxx))

### 0.9.0 / 2020-02-28

[full changelog](http://github.com/yolk/valvat/compare/v0.8.2...v0.9.0)

* Validate new dutch 2020 vat identification number (by [yvonnenieuwerth](https://github.com/yvonnenieuwerth))
* Set the country adjectives to masculine in FR locales (by [bobmaerten](https://github.com/bobmaerten))
* Fix greek country adjectif in french (by [bobmaerten](https://github.com/bobmaerten))

### 0.8.2 / 2019-11-15

[full changelog](http://github.com/yolk/valvat/compare/v0.8.1...v0.8.2)

* Fixed checksum computation for Slovenian VAT ID.
* Updated normalize regexp to clean spaces, punctuation and control chars (by [jarthod](https://github.com/jarthod))

### 0.8.1 / 2019-07-30

[full changelog](http://github.com/yolk/valvat/compare/v0.8.0...v0.8.1)

* Added Norwegian translation (by [erikaxel](https://github.com/erikaxel))

### 0.8.0 / 2019-07-19

[full changelog](http://github.com/yolk/valvat/compare/v0.7.4...v0.8.0)

* Added support for new IE vat number format, with 2 letters (by [lluis](https://github.com/lluis))
* Added support for spanish NIE Y and Z in checksums (by [descala](https://github.com/descala))
* Added catalan translation (by [descala](https://github.com/descala))
* Fixed spanish invalid vat message (by [descala](https://github.com/descala))

### 0.7.4 / 2018-11-21

[full changelog](http://github.com/yolk/valvat/compare/v0.7.3...v0.7.4)

* Fixed HU and SK translations

### 0.7.3 / 2018-11-21

[full changelog](http://github.com/yolk/valvat/compare/v0.7.2...v0.7.3)

* Added Hungarian & Slovakian translations (by [tomas-radic](https://github.com/tomas-radic))

### 0.7.2 / 2018-02-26

[full changelog](http://github.com/yolk/valvat/compare/v0.7.1...v0.7.2)

* Added support for GB vats checksum validation (by [ivopashov](https://github.com/ivopashov))
* Corrected dutch language support (by [ploomans](https://github.com/ploomans))

### 0.7.1 / 2017-06-21

[full changelog](http://github.com/yolk/valvat/compare/v0.7.0...v0.7.1)

* Allow to require all functionality except lookup with 'valvat/local'

### 0.7.0 / 2017-05-16

[full changelog](http://github.com/yolk/valvat/compare/v0.6.11...v0.7.0)

* Improved regex for Cyprus, Estonia, and Lithuania (by [ndnenkov](https://github.com/ndnenkov))
* Added checksum validations for Cyprus, Estonia, Lithuania, Romania, Malta, Hungary, and Croatia (by [ndnenkov](https://github.com/ndnenkov))

### 0.6.11 / 2017-04-07

[full changelog](http://github.com/yolk/valvat/compare/v0.6.10...v0.6.11)

* Removed fakeweb tests and dependency
* Add French checksum validation (by [0ctobat](https://github.com/0ctobat))
* Test against current ruby (2.4) and activemodel (5.0) versions

### 0.6.10 / 2015-05-29

[full changelog](http://github.com/yolk/valvat/compare/v0.6.9...v0.6.10)

* Added finish translations (by [kaapa](https://github.com/kaapa))

### 0.6.9 / 2015-03-19

[full changelog](http://github.com/yolk/valvat/compare/v0.6.8...v0.6.9)

* Added catalan translations (by [descala](https://github.com/descala))
* Added support for spanish NIE Y and Z (by [descala](https://github.com/descala))
* Fixed spanish translations (by [Carlos Hernández Medina](https://github.com/polimorfico))

### 0.6.8 / 2014-12-18

[full changelog](http://github.com/yolk/valvat/compare/v0.6.7...v0.6.8)

* Added cert to allow valvat to be installed with `gem install valvat -P MediumSecurity` (more info: http://guides.rubygems.org/security/)
* Removed all circular require-statements - fixed #34 (by [Julik Tarkhanov](https://github.com/julik))
* Fixed segfault with activemodel requiring files with .rb-suffix - fixed #34 (by [Julik Tarkhanov](https://github.com/julik))

### 0.6.7 / 2014-11-03

[full changelog](http://github.com/yolk/valvat/compare/v0.6.6...v0.6.7)

* Fixed SOAP issue with current wasabi 3.3 - fixed #33
* Several minor travis/guard fixes

### 0.6.6 / 2014-10-02

[full changelog](http://github.com/yolk/valvat/compare/v0.6.5...v0.6.6)

* Added czech translations (by [Dawid Cichuta](https://github.com/cichaczem))
* Fixed polish translations (by [Dawid Cichuta](https://github.com/cichaczem))

### 0.6.5 / 2014-06-19

[full changelog](http://github.com/yolk/valvat/compare/v0.6.4...v0.6.5)

* Added french, spanish and danish translations (by [Roman Lehnert](https://github.com/romanlehnert))
* Specs: Fixed issues with rspec 3
* Specs: Switched to :expect syntax

### 0.6.4 / 2014-04-09

[full changelog](http://github.com/yolk/valvat/compare/v0.6.3...v0.6.4)

* Added dutch translations (by [0scarius](https://github.com/0scarius))

### 0.6.3 / 2014-04-05

[full changelog](http://github.com/yolk/valvat/compare/v0.6.2...v0.6.3)

* Fixed portuguese translations (by [Davidslv](https://github.com/Davidslv))

### 0.6.2 / 2013-11-10

[full changelog](http://github.com/yolk/valvat/compare/v0.6.1...v0.6.2)

* Added blank? method to Valvat object

### 0.6.1 / 2013-09-02

[full changelog](http://github.com/yolk/valvat/compare/v0.6.0...v0.6.1)

* Valvat::Lockup: require savon on load

### 0.6.0 / 2013-08-01

[full changelog](http://github.com/yolk/valvat/compare/v0.5.0...v0.6.0)

* Works now with current version of savon gem (2.3.0) (by [liggitt](https://github.com/liggitt))
* Corrected regex for IE VAT numbers (by [brianphillips](https://github.com/brianphillips))
* Improved PT translation
* Some code refactorings
* Spec improvments

### 0.5.0 / 2013-07-18

[full changelog](http://github.com/yolk/valvat/compare/v0.4.7...v0.5.0)

* Added experimental checksum verification for 17 european countries (with help from [kirichkov](https://github.com/kirichkov))
* Works now with current version of savon gem (2.2.0) (by [nevesenin](https://github.com/nevesenin))

### 0.4.7 / 2013-07-18

[full changelog](http://github.com/yolk/valvat/compare/v0.4.6...v0.4.7)

* Added I18n locales for Polish, Romanian, Italian, Portuguese and Latvian (by [shaundaley39](https://github.com/shaundaley39))

### 0.4.6 / 2013-07-01

[full changelog](http://github.com/yolk/valvat/compare/v0.4.5...v0.4.6)

* Added support for croatian vat numbers (by [mowli](https://github.com/mowli))

### 0.4.5 / 2013-02-16

[full changelog](http://github.com/yolk/valvat/compare/v0.4.4...v0.4.5)

* Added I18n locales in bulgarian (by [kirichkov](https://github.com/kirichkov))

### 0.4.4 / 2013-01-07

[full changelog](http://github.com/yolk/valvat/compare/v0.4.3...v0.4.4)

* Fixed dependency on savon version 1.2 (2.0 uses new api)
* Convert to string before normalize (by [borodiychuk](https://github.com/borodiychuk))

### 0.4.3 / 2012-12-11

[full changelog](http://github.com/yolk/valvat/compare/v0.4.2...v0.4.3)

* Fixed error handling in Lookup (by [bmurzeau](https://github.com/bmurzeau))

### 0.4.2 / 2012-11-16

[full changelog](http://github.com/yolk/valvat/compare/v0.4.1...v0.4.2)

* Fixed usage with savon version 1.2
* Require version 1.2 of the savon gem from now on
* Added :raise_error option to throw errors instead of returning nil

### 0.4.1 / 2012-07-17

[full changelog](http://github.com/yolk/valvat/compare/v0.4.0...v0.4.1)

* Fixed issue with current savon version & required more recent savon version

### 0.4.0 / 2012-07-17

[full changelog](http://github.com/yolk/valvat/compare/v0.3.6...v0.4.0)

* Added support for company details and requester identifiers in successful responses
(by [lcx](https://github.com/lcx))
* Added Valvat::Lookup.last_error for debugging

### 0.3.6 / 2012-04-10

[full changelog](http://github.com/yolk/valvat/compare/v0.3.5...v0.3.6)

* Fixed wrong regexp for Belgium numbers (by [opsidao](https://github.com/opsidao))

### 0.3.5 / 2012-02-02

[full changelog](http://github.com/yolk/valvat/compare/v0.3.4...v0.3.5)

* Swedish translation (by [henrik](https://github.com/henrik))
* English fixes (by [henrik](https://github.com/henrik))

### 0.3.4 / 2011-08-01

[full changelog](http://github.com/yolk/valvat/compare/v0.3.3...v0.3.4)

* Normalize all input on initialization (by [SpoBo](https://github.com/SpoBo))

### 0.3.3 / 2011-06-02

[full changelog](http://github.com/yolk/valvat/compare/v0.3.2...v0.3.3)

* Add Valvat::Utils.iso_country_to_vat_country (by [Deb Bassett](https://github.com/urbanwide))

### 0.3.2 / 2011-01-14

[full changelog](http://github.com/yolk/valvat/compare/v0.3.1...v0.3.2)

* Fixed localization strings (en/de)
* Moved locales folder to lib/valvat/locales

### 0.3.1 / 2011-01-12

[full changelog](http://github.com/yolk/valvat/compare/v0.3.0...v0.3.1)

* ActiveModel validation: Failed validations with _match_country_ now use error message with country from given attribute
* ActiveModel validation: Failed validations with _match_country_ skip lookup and syntax checks

### 0.3.0 / 2011-01-12

[full changelog](http://github.com/yolk/valvat/compare/v0.2.3...v0.3.0)

* ActiveModel validation: added _match_country_ option to validate if iso country code of vat number matches another attribute.

### 0.2.3 / 2011-01-10

[full changelog](http://github.com/yolk/valvat/compare/v0.2.2...v0.2.3)

* Valvat::Utils.normalize now removes spaces and special chars anywhere

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
