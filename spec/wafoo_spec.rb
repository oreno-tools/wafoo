require 'spec_helper'

describe 'wafoo check version' do
  it 'has a version number' do
    expect(Wafoo::VERSION).not_to be nil
  end

  it 'has a version number by cli' do
    output = capture(:stdout) { Wafoo::CLI.start(%w{version}) }
    expect(output).to match(Wafoo::VERSION)
  end
end
