# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Lookup::Response do
  it 'removes @xmlns from :check_vat_response hash' do
    expect(described_class.new({
                                 check_vat_response: { :a => 1, :b => 2, :@xmlns => true }
                               }).to_hash).to eql({ a: 1, b: 2 })
  end

  it "removes 'trader_'-Prefixes :check_vat_response hash" do
    expect(described_class.new({
                                 check_vat_response: { a: 1, trader_b: 2 }
                               }).to_hash).to eql({ a: 1, b: 2 })
  end

  it 'accepts hash keyed as :check_vat_approx_response' do
    expect(described_class.new({
                                 check_vat_approx_response: { a: 1, b: 2 }
                               }).to_hash).to eql({ a: 1, b: 2 })
  end

  it 'allows direct access to hash via []' do
    expect(described_class.new({
                                 check_vat_response: { a: 123, b: 2 }
                               })[:a]).to be(123)
  end
end
