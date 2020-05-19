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
    expect = {:action => "DELETE",
              :ip_set_descriptor => {:type => "IPV4", :value => "192.168.0.1/32"}}
    expect(expect).to match(actual)
  end

  it 'check generate_insert_hash' do
    ip_list = '+192.168.0.1/32'
    actual = Wafoo::Run.new.generate_insert_hash(ip_list)
    expect = {:action => "INSERT",
              :ip_set_descriptor => {:type => "IPV4", :value => "192.168.0.1/32"}}
    expect(expect).to match(actual)
  end

  it 'check get_waf_ipsets' do
    actual = Wafoo::Run.new.get_waf_ipsets
    expect = [["WAF", "1234567-abcd-1234-efgh-5678-1234567890", "waf-my-ip-set1"],
              ["WAF", "2234567-abcd-1234-efgh-5678-1234567890", "waf-my-ip-set2"],
              ["WAF", "3234567-abcd-1234-efgh-5678-1234567890", "waf-my-ip-set3"]]
    expect(expect).to match(actual)
  end

  it 'check get_wafregional_ipsets' do
    actual = Wafoo::Run.new.get_wafregional_ipsets
    expect = [["WAFRegional", "1234567-abcd-1234-efgh-5678-1234567890", "regional-my-ip-set1"],
              ["WAFRegional", "2234567-abcd-1234-efgh-5678-1234567890", "regional-my-ip-set2"],
              ["WAFRegional", "3234567-abcd-1234-efgh-5678-1234567890", "regional-my-ip-set3"]]
    expect(expect).to match(actual)
  end

  it 'check list_ipsets' do
    actual = capture(:stdout) { Wafoo::Run.new.list_ipsets }
    expect = <<"EOS"
+-------------+----------------------------------------+---------------------+
| Type        | IPSet ID                               | IPSet Name          |
+-------------+----------------------------------------+---------------------+
| WAF         | 1234567-abcd-1234-efgh-5678-1234567890 | waf-my-ip-set1      |
| WAF         | 2234567-abcd-1234-efgh-5678-1234567890 | waf-my-ip-set2      |
| WAF         | 3234567-abcd-1234-efgh-5678-1234567890 | waf-my-ip-set3      |
| WAFRegional | 1234567-abcd-1234-efgh-5678-1234567890 | regional-my-ip-set1 |
| WAFRegional | 2234567-abcd-1234-efgh-5678-1234567890 | regional-my-ip-set2 |
| WAFRegional | 3234567-abcd-1234-efgh-5678-1234567890 | regional-my-ip-set3 |
+-------------+----------------------------------------+---------------------+
EOS
    expect(expect).to eq actual
  end

  it 'check list_ipsets with `--full` option' do
    actual = capture(:stdout) { Wafoo::Run.new({'full': true}).list_ipsets }
    expect = <<"EOS"
+-------------+----------------------------------------+---------------------+----------------------+---------------+
| Type        | IPSet ID                               | IPSet Name          | WebACL ID            | WebACL Name   |
+-------------+----------------------------------------+---------------------+----------------------+---------------+
| WAF         | 1234567-abcd-1234-efgh-5678-1234567890 | waf-my-ip-set1      | webacl-1472061481310 | WebACLexample |
| WAF         | 2234567-abcd-1234-efgh-5678-1234567890 | waf-my-ip-set2      |                      |               |
| WAF         | 3234567-abcd-1234-efgh-5678-1234567890 | waf-my-ip-set3      |                      |               |
| WAFRegional | 1234567-abcd-1234-efgh-5678-1234567890 | regional-my-ip-set1 | webacl-1472061481310 | WebACLexample |
| WAFRegional | 2234567-abcd-1234-efgh-5678-1234567890 | regional-my-ip-set2 |                      |               |
| WAFRegional | 3234567-abcd-1234-efgh-5678-1234567890 | regional-my-ip-set3 |                      |               |
+-------------+----------------------------------------+---------------------+----------------------+---------------+
EOS
    expect(expect).to eq actual
  end
end
