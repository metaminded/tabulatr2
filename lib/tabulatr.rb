#--
# Copyright (c) 2010-2014 Peter Horn & Florian Thomas, metaminded UG
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

  mattr_accessor :spinner, :paginate, :filter, :search, :paginate,
    :pagesize, :sortable, :batch_actions, :footer_content, :path,
    :order_by, :html_class, :pagination_position, :counter_position,
    :persistent, :theme

  self.filter = true                  # false for no filter row at all
  self.search = true                  # show fuzzy search field
  self.paginate = true                # true to show paginator
  self.pagesize = 20                  # default pagesize
  self.sortable = true                # true to allow sorting (can be specified for every sortable column)
  self.batch_actions = false          # :name => value hash of batch action stuff
  self.footer_content = false         # if given, add a <%= content_for <footer_content> %> before the </table>
  self.path = '#'                     # where to send the AJAX-requests to
  self.order_by = nil                 # default order
  self.html_class = ''
  self.pagination_position = :top
  self.counter_position = :top
  self.persistent = true
  self.spinner  = :standard
  self.theme = :bs3

end

require 'tabulatr/engine'
require 'tabulatr/renderer/renderer'
require 'tabulatr/data/data'
require 'tabulatr/json_builder'
require 'tabulatr/params_builder'
require 'tabulatr/generators/railtie' if defined?(Rails)
require 'tabulatr/responses/responses'

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
