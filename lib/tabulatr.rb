#--
# Copyright (c) 2010-2011 Peter Horn, Provideal GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
module Tabulatr
  def self.config &block
    yield self
  end

  mattr_accessor :bootstrap_paginator, instance_accessor: false do
    'create_ul_paginator'
  end

  def self.secret_tokens=(secret_tokens)
    @@secret_tokens = secret_tokens
  end

  def self.secret_tokens
    @@secret_tokens ||= []
  end
end

require 'tabulatr/engine'
require 'tabulatr/dummy_record'
require 'tabulatr/settings'
require 'tabulatr/renderer/renderer'
require 'tabulatr/data/data'
require 'tabulatr/json_builder'
require 'tabulatr/generators/railtie' if defined?(Rails)
require 'whiny_hash'

#--
# Mainly Monkey Patching...
#--
Dir[File.join(File.dirname(__FILE__), "tabulatr", "rails", "*.rb")].each do |file|
  require file
end

#---
# Utility methods
#--
Dir[File.join(File.dirname(__FILE__), "tabulatr", "utility", "*.rb")].each do |file|
  require file
end


#--
# Renderer methods
#--
#---
# Utility methods
#--
# Dir[File.join(File.dirname(__FILE__), "tabulatr", "renderer", "row_builder.rb")].each do |file|
#   require file
# end
Dir[File.join(File.dirname(__FILE__), "tabulatr", "renderer", "*.rb")].each do |file|
  require file
end

