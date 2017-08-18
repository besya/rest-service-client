# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.dirname(__FILE__) + '/lib/restserviceclient/version'

Gem::Specification.new do |spec|
  spec.name          = 'rest-service-client'
  spec.version       = RestServiceClient::VERSION
  spec.authors       = ['Igor Bespalov']
  spec.email         = ['gravisbesya@list.ru']

  spec.summary       = 'DSL for rest-client'
  spec.homepage      = 'https://github.com/besya/rest-service-client'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'

  spec.add_dependency 'rest-client'
  spec.add_dependency 'json'
end
