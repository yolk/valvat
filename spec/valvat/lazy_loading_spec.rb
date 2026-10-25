# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'rbconfig'

describe 'require "valvat"' do
  it 'loads the lookup and REXML on first use only' do
    script = 'require "valvat"; print defined?(REXML).inspect; Valvat::Lookup; print " ", defined?(REXML).inspect'
    lib = File.expand_path('../../lib', __dir__)
    output, status = Open3.capture2(RbConfig.ruby, '-I', lib, '-e', script)

    expect(status).to be_success
    expect(output).to eq('nil "constant"')
  end
end
