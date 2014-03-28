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

module Tabulatr::Data::Sorting

  def apply_sorting(sortparam)
    if sortparam.present?
      clname, orientation = sortparam.split(' ')
      if clname[':']
        splitted = clname.split(':')
      else
        splitted = clname.split('.')
      end
      if splitted.count == 2
        assoc_name = splitted[0].to_sym
        name = splitted[1].to_sym
        column = table_columns.find{|c| c.table_name == assoc_name && c.name == name}
      else
        name = splitted[0].to_sym
        column = table_columns.find{|c| c.name == name}
      end
      sort_by(column, orientation)
    else
      @relation = @relation.reorder("#{@table_name}.#{@base.primary_key} desc")
    end
  end

  def sort_by(column, orientation)
      sort_sql = column.sort_sql
      if sort_sql.respond_to? :call
        @relation = sort_sql.call(@relation, orientation, "#{@table_name}.#{@base.primary_key}", @base)
      else
        @relation = @relation.reorder("#{sort_sql} #{orientation}")
      end
  end

end

Tabulatr::Data.send :include, Tabulatr::Data::Sorting
