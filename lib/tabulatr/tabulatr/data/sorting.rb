module Tabulatr::Data::Sorting

  def apply_sorting(sortparam, default_order='id desc')
    if sortparam.present?
      sort_by, orientation = sortparam.split(' ')
      nn = build_column_name sortparam, use_for: :sort
      raise "asasa" unless ['asc', 'desc'].member(orientation.downcase)
      @relation = @relation.order("#{nn} #{orientation}")
    else
      @relation = @relation.order(default_order || "#{@table_name}.#{@klaz.primary_key} asc")
    end
  end

end

Tabulatr::Data.send :include, Tabulatr::Data::Sorting
