require 'wafoo'

module Wafoo
  class Run
    IP_SETS_DIR = 'ipsets'
    include Wafoo::Helper
  
    def initialize(options = nil)
      # Stub は個別にロードしてあげないといけないので苦肉の策
      Wafoo::Stub.load('waf') if ENV['LOAD_STUB'] == 'true'
      @waf = Aws::WAF::Client.new
      @waf_webacls = get_waf_webacls

      # Stub は個別にロードしてあげないといけないので苦肉の策
      Wafoo::Stub.load('wafregional') if ENV['LOAD_STUB'] == 'true'
      @waf_regional = Aws::WAFRegional::Client.new
      @wafregioal_webacls = get_wafregional_webacls

      @all_waf_webacls = @waf_webacls + @wafregioal_webacls

      @regional = options[:regional] unless options.nil?
      FileUtils.mkdir_p(IP_SETS_DIR) unless FileTest.exist?(IP_SETS_DIR)
    end

    %w(waf wafregional).each do |kind|
      define_method "get_#{kind}_webacls" do
        webacls = []
        params = {}
        waf_client = (kind == 'waf' ? @waf : @waf_regional)
        loop do
          res = waf_client.list_web_acls(params)
          res.web_acls.map(&:to_h).each do |acl|
            acl[:web_acl_name] = acl[:name]
            acl.delete(:name)
            webacls << acl
          end
          break if res.next_marker.nil?
          params[:next_marker] = res.next_marker
        end

        webacl_ids = webacls.map {|acl| acl[:web_acl_id] }
        webacl_ids.each do |id|
          acl = waf_client.get_web_acl({
            web_acl_id: id,
          })
          rules = []
          acl.web_acl.rules.map(&:to_h).each do |r|
            rule_desc = waf_client.get_rule({
              rule_id: r[:rule_id]
            })
            ip_sets = rule_desc.rule.predicates.map { |p| p.data_id if p.type == 'IPMatch' }
            rule = {}
            rule[:rule_id] = r[:rule_id]
            rule[:ip_set_ids] = ip_sets
            rules << rule
          end

          webacls.map do |_acl|
            _acl[:web_acl_rules] = rules if id == _acl[:web_acl_id]
          end
        end
        webacls
      end
    end

    def read_ipset_from_api(ip_set_id)
      waf = @regional ? @waf_regional : @waf
      resp = waf.get_ip_set({
        ip_set_id: ip_set_id
      })
      ipsets = []
      sorted_ipsets = resp.ip_set.ip_set_descriptors.sort {|a,b| a[:value] <=> b[:value]}
      sorted_ipsets.each do |ipset|
        ipsets << ipset.value
      end

      ipsets
    end

    def read_ipset_from_file(ip_set_id)
      ipsets = []
      File.open(IP_SETS_DIR + '/' + ip_set_id, 'r') do |file|
        file.read.split("\n").each do |ipset|
          ipsets << ipset
        end
      end

      ipsets.sort
    end

    def select_webacl_id(ip_set_id)
      webacl_ids = []
      @all_waf_webacls.each do |w|
        w[:web_acl_rules].each do |r|
          webacl_ids << w[:web_acl_id] if r[:ip_set_ids].include?(ip_set_id)
        end
      end
      webacl_ids.join('\n') if webacl_ids.length > 1
      webacl_ids[0]
    end

    def select_webacl_name(ip_set_id)
      webacl_names = []
      @all_waf_webacls.each do |w|
        w[:web_acl_rules].each do |r|
          webacl_names << w[:web_acl_name] if r[:ip_set_ids].include?(ip_set_id)
        end
      end
      webacl_names.join('\n') if webacl_names.length > 1
      webacl_names[0]
    end

    def get_waf_ipsets
      ip_sets = []
      params = {}
      loop do
        res = @waf.list_ip_sets(params)
        res.ip_sets.each do |set|
          ipset = []
          ipset << @waf.class.to_s.split('::')[1]
          ipset << set.ip_set_id
          ipset << set.name
          ipset << select_webacl_id(set.ip_set_id)
          ipset << select_webacl_name(set.ip_set_id)
          ip_sets << ipset
        end
        break if res.next_marker.nil?
        params[:next_marker] = res.next_marker
      end
      ip_sets
    end

    def get_wafregional_ipsets
      ip_sets = []
      params = {}
      loop do
        res = @waf_regional.list_ip_sets(params)
        res.ip_sets.each do |set|
          ipset = []
          ipset << @waf_regional.class.to_s.split('::')[1]
          ipset << set.ip_set_id
          ipset << set.name
          ipset << select_webacl_id(set.ip_set_id)
          ipset << select_webacl_name(set.ip_set_id)
          ip_sets << ipset
        end
        break if res.next_marker.nil?
        params[:next_marker] = res.next_marker
      end
      ip_sets
    end

    def list_ipsets
      ip_sets = []
      ip_sets = get_waf_ipsets + get_wafregional_ipsets
      output_table(ip_sets)
    end

    def export_ipset(ip_set_id)
      puts 'Exporting IP List...'
      begin
        ipsets = read_ipset_from_api(ip_set_id)
      rescue => ex
        puts error_print(ex.message)
        exit 1
      end
      ipsets.sort.each { |ipset| puts info_print(ipset) }
      File.open(IP_SETS_DIR + '/' + ip_set_id, 'w') do |f|
        ipsets.sort.each { |ipset| f.puts(ipset) }
      end
      puts 'Exported to ' + added_print(IP_SETS_DIR + '/' + ip_set_id)
    end

    def apply_ipset(ipsets, ip_set_id)
      waf = @regional ? @waf_regional : @waf
      puts 'Applying IP List...'
      change_token = waf.get_change_token.change_token
      begin
        waf.update_ip_set(
          ip_set_id: ip_set_id,
          change_token: change_token,
          updates: ipsets
        )
        puts 'Apply Finished.'
        exit 0
      rescue => ex
        puts error_print(ex.message)
        exit 1
      end
    end

    def create_ipset(ip_set_name)
      waf = @regional ? @waf_regional : @waf
      puts 'Creating IPSet...'
      change_token = waf.get_change_token.change_token
      begin
        waf.create_ip_set(
          name: ip_set_name,
          change_token: change_token,
        )
        puts 'Create Finished.'
        exit 0
      rescue => ex
        puts error_print(ex.message)
        exit 1
      end
    end

    def generate_delete_hash(ipset)
      ipset.slice!(0)
      ipset_hash = {
                       action: 'DELETE',
                       ip_set_descriptor: {
                         type: 'IPV4',
                         value: ipset
                       }
                   }
      ipset_hash
    end

    def generate_insert_hash(ipset)
      ipset.slice!(0)
      ipset_hash = {
                       action: 'INSERT',
                       ip_set_descriptor: {
                         type: 'IPV4',
                         value: ipset
                       }
                   }
      ipset_hash
    end

    def update_ipset(ip_set_id, dry_run)
      _old = read_ipset_from_api(ip_set_id).join("\n")
      _new = read_ipset_from_file(ip_set_id).join("\n")
      ipsets = []
      Diffy::Diff.new(_old, _new).each do |line|
        case line
          when /^\+/ then
            puts 'Add Line: ' + added_print(line.chomp)
            ipsets << generate_insert_hash(line.chomp)
          when /^-/ then
            puts 'Remove Line: ' + removed_print(line.chomp)
            ipsets << generate_delete_hash(line.chomp)
        end
      end

      if !dry_run and ipsets.length > 0 then
        apply_ipset(ipsets.flatten, ip_set_id)
        export_ipset(ip_set_id)
      elsif dry_run and ipsets.length > 0 then
        puts 'Above IP list will be changed.'
        exit 0
      else
        puts 'No IP list changed.'
        exit 0
      end
    end
  end
end
