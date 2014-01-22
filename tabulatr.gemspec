# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tabulatr/version"

Gem::Specification.new do |s|
  s.name        = "tabulatr2"
  s.version     = Tabulatr::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = "A tight DSL to build tables of ActiveRecord "+
                  "models with sorting, pagination, finding/filtering, "+
                  "selecting and batch actions."
  s.email       = "info@provideal.net"
  s.homepage    = "http://github.com/provideal/tabulatr2"
  s.description = "A tight DSL to build tables of ActiveRecord "+
                  "models with sorting, pagination, finding/filtering, "+
                  "selecting and batch actions. " +
                  "Tries to do for tables what formtastic and simple_form did "+
                  "for forms."
  s.authors     = ['Peter Horn', 'René Sprotte', 'Florian Thomas']
  s.license       = 'MIT'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.rdoc_options  = ['--charset=UTF-8']


  s.add_runtime_dependency('rails', '>= 4.0.0')
  s.add_dependency('slim', '>= 2.0.1')
  s.add_runtime_dependency('activerecord_outer_joins', '~> 0.0.1')
  s.add_development_dependency('rubysl', '~> 2.0') if RUBY_ENGINE = 'rbx'
end
