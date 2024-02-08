# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Lookup::BFS do
  it 'returns hash with valid: true on success' do
    response = described_class.new('CHE343663860 MWST', ch: true).perform

    expect(response).to eq({ valid: true })
  end

  it 'returns hash that includes valid: false on invalid input' do
    response = described_class.new('CHE-343.663.86MWST', ch: true).perform
    expect(response).to match({
                                detail: nil,
                                faultcode: 's:Client',
                                faultstring: 'Data_validation_failed',
                                valid: false
                              })
  end
end
