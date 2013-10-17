module Tabulatr::Data::Filtering

  def apply_search(query)
    like ||= Tabulatr::Utility.like_statement
    return unless query.present?
    if @search.is_a? Array
      query = query.strip.gsub(/['*%\s]+/, '%')
      a = @search.map do |nam|
        nn = build_column_name name, use_for: :filter
        "(#{nn} #{like} '%#{query}%')"
      end
      a = a.join(' OR ')
      @relation = @relation.where(a)
    else # search is a proc
      @relation = @relation.where(@search.(query))
    end
  end

  def apply_filters(filter_params)
    return unless filter_params
    assoc_filters = filter_params.delete :__association
    apply_association_filters(assoc_filters) if assoc_filters.present?
    filter_params.each do |filter|
      name, value = filter
      next unless value.present?
      nn = build_column_name name, use_for: :filter
      apply_condition(nn, value)
    end
  end

  def apply_association_filters(assoc_filters)
    assoc_filters.each do |assoc_filter|
      name, value = assoc_filter
      assoc, att = name.split(".").map(&:to_sym)
      table_name = table_name_for_association(assoc)
      nn = build_column_name(att, table_name: table_name, use_for: :filter)
      apply_condition(nn, value)
    end
  end

  def apply_condition(n,v)
    like ||= Tabulatr::Utility.like_statement
    if v.is_a?(String)
      @relation = @relation.where("#{n} = ?", v) unless v.blank?
    elsif v.is_a?(Hash)
      if v[:like].present?
        @relation = @relation.where("#{n} #{like} ?", "%#{v[:like]}%")
      else
        @relation = @relation.where("#{n} >= ?", "#{v[:from]}") if v[:from].present?
        @relation = @relation.where("#{n} <= ?", "#{v[:to]}") if v[:to].present?
      end
    else
      raise "Wrong filter type: #{v.class}"
    end
  end

end

Tabulatr::Data.send :include, Tabulatr::Data::Filtering
