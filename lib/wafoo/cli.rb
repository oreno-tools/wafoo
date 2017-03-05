# coding: utf-8

require 'thor'
require 'aws-sdk'
require 'awsecrets'
require 'diffy'
require 'netaddr'

module Wafoo
  class CLI < Thor
    default_command :version
    class_option :profile
    class_option :region

    desc 'version', 'version 情報を出力.'
    def version
      puts VERSION
    end

    desc 'list', 'IPSet ID の一覧を取得する'
    option :cloudfront, type: :boolean, desc: '対象が CloudFront の場合に指定.'
    def list
      puts 'listing...'
      list_ipsets
    end

    desc 'export', '指定した IPSet ID の IPset を export する'
    # option :file, type: :string, aliases: '-f', desc: 'IPset 出力先を指定.'
    option :ip_set_id, type: :string, aliases: '-i', desc: 'IPset ID を指定.'
    option :cloudfront, type: :boolean, desc: '対象が CloudFront の場合に指定.'
    def export
      puts 'export...'
      export_ipsets(options[:ip_set_id])
    end

    desc 'apply', '指定した IPSet ID の IPset を apply する'
    # option :file, type: :string, aliases: '-f', desc: 'IPset 入力元を指定.'
    option :ip_set_id, type: :string, aliases: '-i', desc: 'IPset ID を指定.'
    option :dry_run, type: :boolean, aliases: '-d', desc: 'apply 前の試行.'
    option :cloudfront, type: :boolean, desc: '対象が CloudFront の場合に指定.'
    def apply
      if options[:dry_run] then
        puts 'apply...(dry-run)'
      else
        puts 'apply...'
      end
      update_ipsets(options[:ip_set_id], options[:dry_run])
    end

    private

    def waf
      Awsecrets.load
      unless options[:cloudfront] then
        Aws::WAFRegional::Client.new(profile: options[:profile], region: options[:region])
      else
        Aws::WAF::Client.new(profile: options[:profile], region: options[:region])
      end
    end

    def read_ipsets_from_api(ip_set_id)
      resp = waf.get_ip_set({
        ip_set_id: ip_set_id
      })
      ipsets = []
      sorted_ipsets = resp.ip_set.ip_set_descriptors.sort {|a,b| a[:value] <=> b[:value]}
      sorted_ipsets.each do |ipset|
        ipsets << ipset.value
      end

      return ipsets
    end

    def read_ipsets_from_file(ip_set_id)
      ipsets = []
      File.open(ip_set_id, 'r') do |file|
        file.read.split("\n").each do |ipset|
          ipsets << ipset
        end
      end

      return ipsets.sort
    end

    def list_ipsets
      waf.list_ip_sets.ip_sets.each do |ipset|
        puts ipset.to_yaml
      end
    end

    def export_ipsets(ip_set_id)
      ipsets = read_ipsets_from_api(ip_set_id)
      ipsets.sort.each { |ipset| puts ipset }
      File.open(ip_set_id, 'w') do |f|
        ipsets.sort.each { |ipset| f.puts(ipset) }
      end
    end

    def apply_ipsets(ipsets, ip_set_id)
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
      else
        ipsets_hash = {
                         action: 'DELETE',
                         ip_set_descriptor: {
                           type: 'IPV4',
                           value: ipset
                         }
                      }
        return ipsets_hash
      end
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
      else
        ipsets_hash = {
                         action: 'INSERT',
                         ip_set_descriptor: {
                           type: 'IPV4',
                           value: ipset
                         }
                      }
        return ipsets_hash
      end
    end

    def update_ipsets(ip_set_id, dry_run)
      _old = read_ipsets_from_api(ip_set_id).join("\n")
      _new = read_ipsets_from_file(ip_set_id).join("\n")
      ipsets = []
      Diffy::Diff.new(_old, _new).each do |line|
        case line
          when /^\+/ then
            puts "#{line.chomp} added."
            ipsets << generate_insert_hash(line.chomp)
          when /^-/ then
            puts "#{line.chomp} removed."
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
