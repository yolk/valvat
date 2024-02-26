# frozen_string_literal: true

require 'spec_helper'

describe Valvat::Lookup::BRREG do
  it 'returns hash with valid: true on success' do
    response = described_class.new('NO997770234MVA', no: true).perform

    expect(response).to include({ valid: true })
  end

  it 'returns hash with valid: false for non-VAT registered companies' do
    response = described_class.new('NO996761134MVA', no: true).perform

    expect(response).to include({ valid: false })
  end

  it 'returns hash that includes valid: false on 404' do
    response = described_class.new('NO123456789MVA', no: true).perform
    expect(response).to eq({ valid: false })
  end
end
