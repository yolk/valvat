valvat
===========

[![rubygems](https://badgen.net/rubygems/v/valvat)](https://rubygems.org/gems/valvat) [![Specs](https://github.com/yolk/valvat/workflows/Specs/badge.svg)](https://github.com/yolk/valvat/actions?query=workflow%3ASpecs)

Validates european vat numbers. Standalone or as a ActiveModel validator.

## A note on Brexit

Valvat supports validating VAT-IDs from the UK by syntax, checksum and using the HMRC API (for backwards compatibility only with the `:uk` option set to true). Validation against the VIES web service stopped working early 2021.

Northern Ireland received its own VAT number prefix - XI which is supported by VIES web service so any XI-prefixed VAT numbers should be validated as any EU VAT number.

## Features

* Simple syntax verification
* Lookup via the VIES web service
* (Optional) lookup via the HMRC web service (for UK VAT numbers)
* ActiveModel/Rails integration
* Works standalone without ActiveModel
* Minimal runtime dependencies
* I18n locales for language specific error messages in English, German, French, Spanish, Italian, Portuguese, Polish, Swedish, Dutch, Danish, Czech, Slovakian, Hungarian, Bulgarian, Romanian, Latvian, Catalan, Norwegian, and Finnish.
* *Experimental* checksum verification

valvat is tested and works with ruby MRI 2.6/2.7/3.0/3.1, jruby and ActiveModel 5/6/7. If you need support for ruby down to 1.9.3 and ActiveModel 3 and 4 use [v1.0.1](https://github.com/yolk/valvat/tree/v1.0.1).

## Installation

Add it to your Gemfile:

```ruby
gem 'valvat'
```

And run:

    $ bundle

Or install it yourself as:

    $ gem install valvat

## Validate the syntax of a VAT number

To verify the syntax of a vat number:

```ruby
Valvat.new("DE345789003").valid?
# => true or false
```

It is also possible to bypass initializing a Valvat instance and check the syntax of a vat number string directly with:

```ruby
Valvat::Syntax.validate("DE345789003")
# => true or false
```

## Validate against the VIES / HMRC web service

To check if the given vat number exists via the VIES or HMRC web service:

```ruby
Valvat.new("DE345789003").exists?
# => true or false or nil
```

Or to lookup a vat number string directly:

```ruby
Valvat::Lookup.validate("DE345789003")
# => true or false or nil
```

To keep backwards compatibility lookups of UK VAT numbers against the HMRC API are only performed with the option `:uk` set to true.

```ruby
Valvat::Lookup.validate("GB553557881", uk: true)
# => true or false or nil
```

Without this option the lookup of UK VAT number always returns `false`.

*IMPORTANT* Keep in mind that the web service might be offline at some time for all or some member states. If this happens `exists?` or `Valvat::Lookup.validate` will return `nil`. See *Handling of maintenance errors* for further details.

### Details & request identifier

If you need all details and not only if the VAT is valid, pass {detail: true} as second parameter to the lookup call.

```ruby
Valvat.new("IE6388047V").exists?(detail: true)
=> {
  :country_code=> "IE", :vat_number => "6388047V", :valid => true,
  :request_date => Date.today, :name=> "GOOGLE IRELAND LIMITED",
  :address=> "1ST & 2ND FLOOR ,GORDON HOUSE ,BARROW STREET ,DUBLIN 4"
} or false or nil
```

According to EU law, or at least as Austria sees it, it's mandatory to verify the VAT number of every new customer, but also to check the VAT number periodicaly. To prove that you have checked the VAT number, the web service can return a `request_identifier`.

To receive a `request_identifier` you need to pass your own VAT number in the options hash. In this example, Google (VAT IE6388047V) is checking the validity of eBays VAT number (LU21416127)

```ruby
Valvat.new("LU21416127").exists?(requester: "IE6388047V")
=> {
  :country_code=>"LU", :vat_number => "21416127", :valid => true,
  :request_date => Date.today, :name=>"EBAY EUROPE S.A R.L.",
  :address => "22, BOULEVARD ROYAL\nL-2449  LUXEMBOURG",
  :company_type => nil, :request_identifier => "some_uniq_string"
} or false or nil
```

If the given `requester` is invalid, a `Valvat::InvalidRequester` error is thrown.

When requesting a `request_identifier` for a GB VAT number, the requester must be your own GB number; a EU VAT number won't work.

Note that when validating UK VAT numbers using the HMRC service, the detail output is modified to match the one from VIES more closely with slight differences remaining:

1. The `request_date` will actually be a (more precise) `Time` instead of a `Date`
2. The `address` string will join lines using `\n` instead of `,` so it's more acurate and can be displayed nicely.

### Handling of maintenance errors

From time to time the VIES web service for one or all member states is down for maintenance. To handle this kind of temporary errors, `Valvat::Lookup#validate` returns `nil` by default to indicate that there is no way at the moment to say if the given VAT is valid or not. You should revalidate the VAT later. If you prefer an error, use the `raise_error` option:

```ruby
Valvat.new("IE6388047V").exists?(raise_error: true)
```

This raises `Valvat::ServiceUnavailable` or `Valvat::MemberStateUnavailable` instead of returning `nil`.

Visit [http://ec.europa.eu/taxation_customs/vies/viesspec.do](http://ec.europa.eu/taxation_customs/vies/viesspec.do) for more accurate information at what time the service for a specific member state will be down.

### Handling of other errors

All other errors accuring while validating against the web service are raised and must be handled by you. These include:

 * `Valvat::InvalidRequester`
 * `Valvat::BlockedError`
 * `Valvat::RateLimitError`
 * `Valvat::Timeout`
 * all IO errors

If you want to suppress all known error cases. Pass in the `raise_error` option set to `false`:

```ruby
Valvat.new("IE6388047V").exists?(raise_error: false)
```

This will return `nil` instead of raising a known error.

### Set options for the Net::HTTP client

Use the `:http` key to set options for the http client. These options are directly passed to `Net::HTTP.start`.

For example to set timeouts:

```ruby
Valvat.new("IE6388047V").exists?(http: { open_timeout: 10, read_timeout: 10 })
```

### Skip local validation before lookup

To prevent unnecessary requests, valvat performs a local syntax check before making the request to the web service. If you want to skip this step (for any reason), set the `:skip_local_validation` option to `true`.

## Experimental checksum verification

valvat allows to check vat numbers from AT, BE, BG, DE, DK, ES, FR, FI, GR, IE, IT, LU, NL, PL, PT, SE and SI against a checksum calculation. All other member states will fall back to a basic syntax check:

```ruby
Valvat.new("DE345789003").valid_checksum?
# => true or false
```

These results are more valuable than a simple syntax check, but keep in mind: they can not replace a lookup via VIES or HMRC.

*IMPORTANT* This feature was tested against all vat numbers I could get my hand on, but it is still marked as *experimental* because these calculations are not documented and may return wrong results.

To bypass initializing a Valvat instance:

```ruby
Valvat::Checksum.validate("DE345789003")
# => true or false
```

## Usage with ActiveModel / Rails

### Loading

When the valvat gem is required and ActiveModel is already loaded, everything will work fine out of the box. If your load order differs just add

```ruby
require 'active_model/validations/valvat_validator'
```

after ActiveModel has been loaded.

### Simple syntax validation

To validate the attribute `vat_number` add this to your model:

```ruby
class MyModel < ActiveRecord::Base
  validates :vat_number, valvat: true
end
```

### Additional lookup validation

To additionally perform an lookup via VIES:

```ruby
validates :vat_number, valvat: { lookup: true }
```

To also perform an lookup via HMRC for UK VAT numbers:

```ruby
validates :vat_number, valvat: { lookup: { uk: true } }
```

By default this will validate to true if the web service is down. To fail in this case simply add the `:fail_if_down` option:

```ruby
validates :vat_number, valvat: { lookup: { fail_if_down: true } }
```

You can pass in any options accepted by `Valvat::Lookup#validate`:

```ruby
validates :vat_number, valvat: { lookup: { raise_error: true, http: { read_timeout: 12 } } }
```

### Additional (and experimental) checksum validation

To additionally perform a checksum validation:

```ruby
validates :vat_number, valvat: { checksum: true }
```

### Additional ISO country code validation

If you want the vat number’s (ISO) country to match another country attribute, use the _match_country_ option:

```ruby
validates :vat_number, valvat: { match_country: :country }
```

where it is supposed that your model has a method named _country_ which returns the country ISO code you want to match.

### Allow blank

By default blank vat numbers validate to false. To change this add the `:allow_blank` option:

```ruby
validates :vat_number, valvat: { allow_blank: true }
```

### Allow vat numbers outside of europe

To allow vat numbers from outside of europe, add something like this to your model (country_code should return a upcase ISO country code):

```ruby
class MyModel < ActiveRecord::Base
  validates :vat_number, valvat: true, if: :eu?

  def eu?
    Valvat::Utils::EU_MEMBER_STATES.include?(country_code)
  end
end
```

## Utilities

To split a vat number into the country code and the remaining chars:

```ruby
Valvat::Utils.split("ATU345789003")
# => ["AT", "U345789003"]
```

or

```ruby
Valvat.new("ATU345789003").to_a
# => ["AT", "U345789003"]
```

Both methods always return an array. If it can not detect the country or the given country is located outside of europe it returns `[nil, nil]`. Please note that this does not strictly return the ISO country code: for greek vat numbers this returns the ISO language code 'EL' instead of the ISO country code 'GR'.

To extract the ISO country code of a given vat number:

```ruby
Valvat.new("EL7345789003").iso_country_code
# => "GR"
```

To extract the vat country code (first two chars in every european vat number):

```ruby
Valvat.new("EL7345789003").vat_country_code
# => "EL"
```

To normalize a vat number:

```ruby
Valvat::Utils.normalize("atu345789003")
# => "ATU345789003"
```

This basically just removes trailing spaces and ensures all chars are uppercase.

## Usage with IPv6

There seems to be a problem when using the VIES service over IPv6. Sadly this is nothing this gem can address. For details and proposed solutions have a look at [this question on StackOverflow](http://stackoverflow.com/questions/15616833/vies-vat-api-soap-error-ipv6). Thanks to George Palmer for bringing up this issue.

## Links

* [VIES web service](http://ec.europa.eu/taxation_customs/vies)
* [HMRC web service](https://developer.service.hmrc.gov.uk/api-documentation/docs/api/service/vat-registered-companies-api/1.0)
* [European vat number formats (german)](http://bzst.de/DE/Steuern_International/USt_Identifikationsnummer/Merkblaetter/Aufbau_USt_IdNr.html)
* [European vat number formats on Wikipedia](http://en.wikipedia.org/wiki/European_Union_Value_Added_Tax)

## Contributions by

https://github.com/yolk/valvat/graphs/contributors

## BlaBla

Copyright (c) 2011-2022 mite GmbH

Beyond that, the implementation is licensed under the MIT License.

Code was originally extracted from our time tracking webapp [mite](https://mite.yo.lk/en/).
