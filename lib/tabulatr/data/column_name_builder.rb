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

module Tabulatr
  class Data
    module ColumnNameBuilder
      #--
      # Access the actual data
      #++
      def build_column_name(colname, table_name: nil, use_for: nil, assoc_name: nil)
        if column_with_table? colname
          t,c = split_column_name_from_table(colname)
          return build_column_name(c, table_name: t, use_for: use_for)
        end
        table_name ||= @table_name
        if table_name == @table_name
          mapping = get_mapping(requested_method: @columns[colname.to_sym], usage: use_for)
          return mapping if mapping.present?
        else
          assoc_name = table_name unless assoc_name
          include_relation! assoc_name
          mapping = get_mapping(requested_method: @assocs[assoc_name.to_sym][colname.to_sym], usage: use_for)
          return mapping if mapping.present?
        end

        complete_column_name table_name, colname
      end

      private

      def split_column_name_from_table column_name
        if column_with_table?(column_name)
          column_name.split('.')
        else
          column_name
        end
      end

      def column_with_table? column_name
        column_name['.']
      end

      def complete_column_name table, column
        t = "#{table}.#{column}"
        raise "SECURITY violation, field name is '#{t}'" unless /^[\d\w]+(\.[\d\w]+)?$/.match t
        t
      end

      def get_mapping requested_method: nil, usage: nil
        return if requested_method.nil? || usage.nil?
        case usage.to_sym
        when :filter
          requested_method[:filter_sql]
        when :sort
          requested_method[:sort_sql]
        end
      end

      def include_relation! name_of_relation
        @includes << name_of_relation.to_sym
      end
    end
  end
end

Tabulatr::Data.send :include, Tabulatr::Data::ColumnNameBuilder
