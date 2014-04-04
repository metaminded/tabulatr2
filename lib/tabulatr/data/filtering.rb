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

module Tabulatr::Data::Filtering

  def apply_search(query)
    like ||= Tabulatr::Utility.like_statement
    return unless query.present?
    if @search.is_a? Array
      query = query.strip.gsub(/['*%\s]+/, '%')
      a = @search.map do |name|
        column = table_columns.find{|c| c.name == name}
        # nn = build_column_name name, use_for: :filter
        "(#{column.filter_sql} #{like} '%#{query}%')"
      end
      a = a.join(' OR ')
      @relation = @relation.where(a)
    else # search is a proc
      execute_provided_search_block!(query)
    end
  end

  def apply_filters(filter_params)
    return unless filter_params
    assoc_filters = filter_params.delete :__association
    apply_association_filters(assoc_filters) if assoc_filters.present?
    filter_params.each do |filter|
      name, value = filter
      next unless value.present?

      table_name, method_name = name.split(':').map(&:to_sym)
      column = table_columns.find{|c| c.table_name == table_name && c.name == method_name}
      apply_condition(column, value)
    end
  end

  def apply_association_filters(assoc_filters)
    assoc_filters.each do |assoc_filter|
      name, value = assoc_filter
      assoc, att = name.split(".").map(&:to_sym)
      table_name = table_name_for_association(assoc)
      column = table_columns.find{|c| c.table_name = table_name && name == name}
      apply_condition(column, value)
    end
  end

  def apply_condition(n,v)
    if ['true', 'false'].include?(v)
      @relation = @relation.where(:"#{n.filter_sql}" => Tabulatr::Utility.string_to_boolean(v))
    elsif v.is_a?(String)
      apply_string_condition("#{n.filter_sql} = ?", v)
    elsif v.is_a?(Hash)
      apply_hash_condition(n, v)
    else
      raise "Wrong filter type: #{v.class}"
    end
  end

  def apply_date_condition(n, cond)
    return unless cond.present?
    today = Date.today
    case cond[:simple]
    when 'none' then return
    when 'today'
      since = today
      to = today.at_end_of_day
    when 'yesterday'
      since = today - 1.day
      to = since.at_end_of_day
    when 'this_week'
      since = today.at_beginning_of_week.beginning_of_day
      to = today.at_end_of_week.end_of_day
    when 'last_7_days'
      since = (today - 6.day).beginning_of_day
      to = today.at_end_of_day
    when 'this_month'
      since = today.at_beginning_of_month.beginning_of_day
      to = today.at_end_of_month.end_of_day
    when 'last_30_days'
      since = (today - 29.day).beginning_of_day
      to = today.at_end_of_day
    when 'from_to'
      since = Date.parse(cond[:from]) if cond[:from].present?
      to = Date.parse(cond[:to]) if cond[:to].present?
    end
    @relation = @relation.where("#{n.filter_sql} >= ?", since) if since.present?
    @relation = @relation.where("#{n.filter_sql} <= ?", to) if to.present?
  end

  def apply_string_condition(replacement_string, value)
     @relation = @relation.where(replacement_string, value) if value.present?
  end

  def apply_hash_condition(column_name, hash)
    like ||= Tabulatr::Utility.like_statement
    apply_string_condition("#{column_name.filter_sql} #{like} ?", "%#{hash[:like]}%") if hash[:like].present?
    apply_date_condition(column_name, hash[:date])
    apply_string_condition("#{column_name.filter_sql} >= ?", "#{hash[:from]}")
    apply_string_condition("#{column_name.filter_sql} <= ?", "#{hash[:to]}")
  end

  private

  def execute_provided_search_block!(query)
    if @search.arity == 1
      search_result = @search.(query)
    elsif @search.arity == 2
      search_result = @search.(query, @relation)
    else
      raise 'Search block needs either `query` or both `query` and `relation` block variables'
    end
    handle_search_result(search_result)
  end

  def handle_search_result(search_result)
    return if search_result.nil?
    if search_result.is_a?(ActiveRecord::Relation)
      @relation = search_result
    elsif search_result.is_a?(String) || search_result.is_a?(Hash) || search_result.is_a?(Array)
      @relation = @relation.where(search_result)
    else
      Tabulatr::UnexpectedSearchResultError.raise_error(search_result.class)
    end
  end

end

Tabulatr::Data.send :include, Tabulatr::Data::Filtering
