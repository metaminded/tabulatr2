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

module Tabulatr::Data::Formatting

  def apply_formats()
    view = Data::Proxy.new
    return @relation.map do |record|
      view.record = record
      h = HashWithIndifferentAccess.new
      @columns.each do |name, opts|
        h[name] = format_column(record, name, opts, view)
      end # @columns each
      @assocs.each do |table_name, columns|
        h[table_name] ||= {}
        columns.each do |name, opts|
          h[table_name][name] = format_association(record, table_name, name, opts, view)
        end
      end # @assocs each
      h
    end # @relation map
  end # apply_formats

  def format_column(record, name, opts, view)
    if opts[:output]
      view.instance_exec(record, &opts[:output])
    else
      record.send(name)
    end
  end

  def format_association(record, table_name, name, opts, view)
    return view.instance_exec(record, &opts[:output]) if opts[:output]
    assoc = record.class.reflect_on_association(table_name.to_sym)
    val = if assoc.collection?
      record.try(table_name).try(:map, &name).join(', ')
    else
      record.try(table_name).try(:send, name)
    end
  end


end

Tabulatr::Data.send :include, Tabulatr::Data::Formatting
