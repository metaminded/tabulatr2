#--
# Copyright (c) 2010-2014 Peter Horn & Florian Thomas, Provideal GmbH
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

class Data::Proxy < ActionView::Base

  attr_accessor :record

  def initialize(record=nil, locals: {})
    self.class._init
    Rails.application.routes.mounted_helpers.instance_methods.each{|f| self.send(f).instance_variable_set('@scope', self)}
    @record = record
    locals.each do |nam, val|
      raise "cowardly refusing to override `#{nam}'" if respond_to? nam
      define_singleton_method nam do val end
    end
  end

  def self._init
    return if @_initialized
    @_initialized = true
    include ActionView::Helpers
    include Rails.application.helpers
    include Rails.application.routes.url_helpers
    include Rails.application.routes.mounted_helpers
  end

end
