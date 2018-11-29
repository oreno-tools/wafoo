require 'wafoo'

module Wafoo
  class CLI < Thor
    Awsecrets.load

    default_command :version
    class_option :profile
    class_option :region

    desc 'version', 'Print version number'
    def version
      puts Wafoo::VERSION
    end

    desc 'list', 'Print IPSet list'
    option :cloudfront, type: :boolean, desc: 'Specify the option when the target is CloudFront.'
    def list
      wafoo = Wafoo::Run.new(options)
      wafoo.list_ipsets
    end

    desc 'export', 'Export IP address list of specified IPSet ID'
    option :ip_set_id, type: :string, aliases: '-i', desc: 'Specify IPset ID.'
    option :regional, type: :boolean, default: false, desc: 'Specify when enabling Regional.'
    def export
      wafoo = Wafoo::Run.new(options)
      wafoo.export_ipset(options[:ip_set_id])
    end

    desc 'apply', 'Apply the specified IPSet ID'
    option :ip_set_id, type: :string, aliases: '-i', desc: 'Specify IPset ID.'
    option :dry_run, type: :boolean, aliases: '-d', desc: 'Dryrun.'
    option :regional, type: :boolean, default: false, desc: 'Specify when enabling Regional.'
    def apply
      wafoo = Wafoo::Run.new(options)
      wafoo.update_ipset(options[:ip_set_id], options[:dry_run])
    end

    desc 'create', 'Create IPSet'
    option :ip_set_name, type: :string, aliases: '-n', desc: 'Specify IPset Name.'
    option :regional, type: :boolean, default: false, desc: 'Specify when enabling Regional.'
    def create
      wafoo = Wafoo::Run.new(options)
      wafoo.create_ipset(options[:ip_set_name])
    end
  end
end

