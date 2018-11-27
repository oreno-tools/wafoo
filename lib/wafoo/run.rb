require 'wafoo'

module Wafoo
  class Run
    include Wafoo::Helper
  
    def initialize(options = nil)
      @waf_regional = Aws::WAFRegional::Client.new
      @waf = Aws::WAF::Client.new
      @regional = options[:regional] unless options.nil?
    end

    def read_ipsets_from_api(ip_set_id)
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

    def read_ipsets_from_file(ip_set_id)
      ipsets = []
      File.open(ip_set_id, 'r') do |file|
        file.read.split("\n").each do |ipset|
          ipsets << ipset
        end
      end

      ipsets.sort
    end

    def list_ipsets
      ip_sets = []
      params = {}
      [ @waf_regional, @waf ].each do |w|
        loop do
          res = w.list_ip_sets(params)
          res.ip_sets.each do |set|
            ipset = []
            ipset << w.class.to_s.split('::')[1]
            ipset << set.ip_set_id
            ipset << set.name
            ip_sets << ipset
          end
          break if res.next_marker.nil?
          params[:next_marker] = res.next_marker
        end
      end
      output_table(ip_sets)
    end

    def export_ipsets(ip_set_id)
      ipsets = read_ipsets_from_api(ip_set_id)
      ipsets.sort.each { |ipset| puts ipset }
      File.open(ip_set_id, 'w') do |f|
        ipsets.sort.each { |ipset| f.puts(ipset) }
      end
    end

    def apply_ipsets(ipsets, ip_set_id)
      waf = @regional ? @waf_regional : @waf
      change_token = waf.get_change_token.change_token
      resp = waf.update_ip_set(
        ip_set_id: ip_set_id,
        change_token: change_token,
        updates: ipsets
      )
    end

    def split_cidr(ipset)
      addr = NetAddr::CIDR.create(ipset)
      addr.enumerate
    end

    def generate_delete_hash(ipset)
      ipset.slice!(0)
      h = {
        action: 'DELETE',
        ip_set_descriptor: {
          type: 'IPV4',
          value: ipset
        }
      }

      unless %w(8 16 24 33).include?(ipset.split('/').last)
        ips = split_cidr(ipset)
        ipsets_array = []
        ips.each do |ip|
          ipsets_array << {
                             action: 'DELETE',
                             ip_set_descriptor: {
                               type: 'IPV4',
                               value: ip + '/32'
                             }
                          }
        end
        return ipsets_array
      end 

      ipsets_hash = {
                       action: 'DELETE',
                       ip_set_descriptor: {
                         type: 'IPV4',
                         value: ipset
                       }
                    }
      ipsets_hash
    end

    def generate_insert_hash(ipset)
      ipset.slice!(0)
      unless %w(8 16 24 33).include?(ipset.split('/').last)
        ips = split_cidr(ipset)
        ipsets_array = []
        ips.each do |ip|
          ipsets_array << {
                             action: 'INSERT',
                             ip_set_descriptor: {
                               type: 'IPV4',
                               value: ip + '/32'
                             }
                          }
        end
        return ipsets_array
      end

      ipsets_hash = {
                       action: 'INSERT',
                       ip_set_descriptor: {
                         type: 'IPV4',
                         value: ipset
                       }
                    }
      ipsets_hash
    end

    def update_ipsets(ip_set_id, dry_run)
      _old = read_ipsets_from_api(ip_set_id).join("\n")
      _new = read_ipsets_from_file(ip_set_id).join("\n")
      ipsets = []
      Diffy::Diff.new(_old, _new).each do |line|
        case line
          when /^\+/ then
            puts added_print(line.chomp)
            ipsets << generate_insert_hash(line.chomp)
          when /^-/ then
            puts removed_print(line.chomp)
            ipsets << generate_delete_hash(line.chomp)
        end
      end

      if dry_run == nil and ipsets.length > 0 then
        apply_ipsets(ipsets.flatten, ip_set_id)
        export_ipsets(ip_set_id)
      end
    end
  end
end
