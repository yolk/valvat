# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Lookup::Fault do
  it "returns {valid: false} on fault 'INVALID_INPUT'" do
    expect(described_class.new({
                                 fault: { faultstring: 'INVALID_INPUT' }
                               }).to_hash).to eql({ valid: false })
  end

  {
    'SERVICE_UNAVAILABLE' => Valvat::ServiceUnavailable,
    'MS_UNAVAILABLE' => Valvat::MemberStateUnavailable,
    'INVALID_REQUESTER_INFO' => Valvat::InvalidRequester,
    'TIMEOUT' => Valvat::Timeout,
    'VAT_BLOCKED' => Valvat::BlockedError,
    'IP_BLOCKED' => Valvat::BlockedError,
    'GLOBAL_MAX_CONCURRENT_REQ' => Valvat::RateLimitError,
    'GLOBAL_MAX_CONCURRENT_REQ_TIME' => Valvat::RateLimitError,
    'MS_MAX_CONCURRENT_REQ' => Valvat::RateLimitError,
    'MS_MAX_CONCURRENT_REQ_TIME' => Valvat::RateLimitError,
    'ANYTHING ELSE' => Valvat::UnknownViesError,
    'REALLY ANYTHING' => Valvat::UnknownViesError
  }.each do |fault, error|
    it "returns error on fault '#{fault}'" do
      expect(described_class.new({
                                   fault: { faultstring: fault }
                                 }).to_hash).to eql({
                                                      error: error.new(fault)
                                                    })
    end
  end
end
