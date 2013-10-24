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

module Tabulatr::Data::DSL

  def column(name, sort_sql: nil, filter_sql: nil, sql: nil, &block)
    @columns ||= HashWithIndifferentAccess.new
    @columns[name.to_sym] = {
      name: name,
      sort_sql: sort_sql || sql,
      filter_sql: filter_sql || sql,
      output: block
    }
  end

  def association(assoc, name, sort_sql: nil, filter_sql: nil, sql: nil, &block)
    @assocs ||= HashWithIndifferentAccess.new
    @assocs[assoc.to_sym] ||= {}
    @assocs[assoc.to_sym][name.to_sym] = {
      name: name,
      sort_sql: sort_sql || sql,
      filter_sql: filter_sql || sql,
      output: block
    }
  end

  def search(*args, &block)
    raise "either column or block" if args.present? && block_given?
    @search = args.presence || block
  end
end

Tabulatr::Data.send :extend, Tabulatr::Data::DSL
