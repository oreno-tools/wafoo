require 'wafoo'

module Wafoo
  class CLI < Thor
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
    option :regional, type: :boolean, default: true, desc: 'Specify the option when the target is CloudFront.'
    def export
      wafoo = Wafoo::Run.new(options)
      wafoo.export_ipsets(options[:ip_set_id])
    end

    desc 'apply', 'Apply the specified IPSet ID'
    option :ip_set_id, type: :string, aliases: '-i', desc: 'Specify IPset ID.'
    option :dry_run, type: :boolean, aliases: '-d', desc: 'Dryrun.'
    option :regional, type: :boolean, default: true, desc: 'Specify the option when the target is CloudFront.'
    def apply
      wafoo = Wafoo::Run.new(options)
      wafoo.update_ipsets(options[:ip_set_id], options[:dry_run])
    end
  end
end

