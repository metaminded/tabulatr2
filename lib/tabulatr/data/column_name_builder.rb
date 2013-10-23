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
