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

  def column(name, sort_sql: nil, filter_sql: nil, sql: nil, table_column_options: {}, &block)
    @columns ||= HashWithIndifferentAccess.new
    table_column = Tabulatr::Renderer::Column.from(table_column_options.merge(name: name, klass: @base))
    @table_columns ||= []
    @table_columns << table_column

    @columns[name.to_sym] = {
      name: name,
      sort_sql: sort_sql || sql,
      filter_sql: filter_sql || sql,
      output: block,
      table_column: table_column
    }
  end

  def association(assoc, name, sort_sql: nil, filter_sql: nil, sql: nil, table_column_options: {}, &block)
    @assocs ||= HashWithIndifferentAccess.new
    @assocs[assoc.to_sym] ||= {}
    @table_columns ||= []
    table_column = Tabulatr::Renderer::Association.from(table_column_options.merge(name: name, table_name: assoc, klass: @base))
    @table_columns << table_column

    @assocs[assoc.to_sym][name.to_sym] = {
      name: name,
      sort_sql: sort_sql || sql,
      filter_sql: filter_sql || sql,
      output: block,
      table_column: table_column
    }
  end

  def search(*args, &block)
    raise "either column or block" if args.present? && block_given?
    @search = args.presence || block
  end

  def checkbox(table_column_options: {})
    @table_columns ||= []
    box = Tabulatr::Renderer::Checkbox.from(table_column_options.merge(klass: @base, filter: false, sortable: false))
    @table_columns << box
  end

  def row &block
    raise 'Please pass a block to row if you want to use it.' unless block_given?
    @row = block
  end

end

Tabulatr::Data.send :extend, Tabulatr::Data::DSL
