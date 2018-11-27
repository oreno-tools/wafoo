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

describe 'Wafoo::Run' do
  it 'check generate_delete_hash' do
    ip_list = '-192.168.0.1/32'
    actual = Wafoo::Run.new.generate_delete_hash(ip_list)
    expect = {:action=>"DELETE",
              :ip_set_descriptor=>{:type=>"IPV4", :value=>"192.168.0.1/32"}}
    expect(expect).to match(actual)
  end

  it 'check generate_insert_hash' do
    ip_list = '+192.168.0.1/32'
    actual = Wafoo::Run.new.generate_insert_hash(ip_list)
    expect = {:action=>"INSERT",
              :ip_set_descriptor=>{:type=>"IPV4", :value=>"192.168.0.1/32"}}
    expect(expect).to match(actual)
  end
end
