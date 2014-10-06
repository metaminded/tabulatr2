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

module Tabulatr::Data::Formatting

  def apply_formats(locals: {}, controller: nil)
    view = Data::Proxy.new(locals: locals, controller: controller)
    return @relation.map do |record|
      view.record = record
      h = HashWithIndifferentAccess.new
      table_columns.each do |tc|
        h[tc.table_name] ||= HashWithIndifferentAccess.new
        h[tc.table_name][tc.name] = tc.value_for(record, view)
      end
      h[:_row_config] = format_row(view, @row)
      h[:id] = record.id
      h
    end # @relation map
  end # apply_formats

  def format_row(view, row)
    row_config = Row.new
    view.instance_exec(view.record, row_config.attributes, &row) if row.is_a?(Proc)
    view.record.define_singleton_method(:_row_config) do
      row_config.attributes
    end
    row_config.attributes
  end
end

Tabulatr::Data.send :include, Tabulatr::Data::Formatting
