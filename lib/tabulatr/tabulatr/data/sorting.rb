module Tabulatr::Data::Sorting

  def apply_sorting(sortparam, default_order=nil)
    if sortparam.present?
      sort_by, orientation = sortparam.split(' ')
      klass = sort_by.split('.').first
      col_name = sort_by.split('.').last
      assoc_name = nil
      if klass == @cname
        table_name = @base.table_name
      else
        assoc_name = @base.reflect_on_association(klass.to_sym).name
        table_name = @base.reflect_on_association(klass.to_sym).table_name
      end
      nn = build_column_name(col_name, table_name: table_name, assoc_name: assoc_name, use_for: :sort)
      raise "asasa" unless ['asc', 'desc'].member?(orientation.downcase)
      @relation = @relation.order("#{nn} #{orientation}")
    else
      @relation = @relation.order(default_order || "#{@table_name}.#{@base.primary_key} asc")
    end
  end

end

Tabulatr::Data.send :include, Tabulatr::Data::Sorting
