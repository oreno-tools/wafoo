# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wafoo/version'

Gem::Specification.new do |spec|
  spec.name          = 'wafoo'
  spec.version       = Wafoo::VERSION
  spec.authors       = ['inokappa']
  spec.email         = ['inokara at gmail.com']

  spec.summary       = %q{AWS WAF is a small tool to manipulate IPSets.}
  spec.description   = %q{AWS WAF is a small tool to manipulate IPSets.}
  spec.homepage      = 'https://github.com/inokappa/wafoo'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = 'TODO: Set to 'http://mygemserver.com''
  # else
  #   raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'octorelease'

  spec.add_dependency 'thor'
  spec.add_dependency 'aws-sdk'
  spec.add_dependency 'awsecrets'
  spec.add_dependency 'diffy'
  spec.add_dependency 'netaddr', '1.5.1'
  spec.add_dependency 'terminal-table'

end
