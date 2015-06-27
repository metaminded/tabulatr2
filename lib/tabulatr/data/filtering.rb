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

module Tabulatr::Data::Filtering

  def apply_search(query)
    like ||= Tabulatr::Utility.like_statement
    return unless query.present?
    if @search.is_a? Array
      query = query.strip.gsub(/['*%\s]+/, '%')
      a = @search.map do |name|
        column = table_columns.find{|c| c.name == name}
        nn = column ? column.filter_sql : name
        # nn = build_column_name name, use_for: :filter
        "(#{nn} #{like} '%#{query}%')"
      end
      a = a.join(' OR ')
      @relation = @relation.where(a)
    else # search is a proc
      execute_provided_search_block!(query)
    end
  end

  def apply_filters(filter_params)
    return unless filter_params
    filter_params.each do |param|
      name, value = param
      next unless value.present?

      apply_condition(find_column(name), value)
    end
  end

  def apply_condition(n,v)
    case n.filter
    when :checkbox then apply_boolean_condition(n, v)
    when :decimal  then apply_string_condition("#{n.col_options.filter_sql} = ?", v.to_f)
    when :integer  then apply_string_condition("#{n.col_options.filter_sql} = ?", v.to_i)
    when :enum     then apply_string_condition("#{n.col_options.filter_sql} = ?", v.to_i)
    when :enum_multiselect then apply_array_condition(n, v)
    when :exact    then apply_string_condition("#{n.col_options.filter_sql} = ?", v)
    when Hash      then apply_string_condition("#{n.col_options.filter_sql} = ?", v)
    when Array     then apply_string_condition("#{n.col_options.filter_sql} = ?", v)
    when :like     then apply_like_condition(n, v[:like])
    when :date     then apply_date_condition(n, v[:date])
    when :range    then apply_range_condition(n, v)
    when :custom   then apply_custom_filter(n, v)
    else raise "Wrong filter type for #{n.name}: #{n.filter}"
    end
  end

  def apply_boolean_condition(column, value)
    @relation = @relation.where("#{column.col_options.filter_sql} = ?", Tabulatr::Utility.string_to_boolean(value))
  end

  def apply_date_condition(n, cond)
    today = Date.today
    yesterday = today - 1.day
    case cond[:simple]
    when 'none' then return
    when 'today' then date_in_between(today, today.at_end_of_day, n)
    when 'yesterday' then date_in_between(yesterday, yesterday.at_end_of_day, n)
    when 'this_week' then date_in_between(today.at_beginning_of_week.beginning_of_day,
                            today.at_end_of_week.end_of_day, n)
    when 'last_7_days' then date_in_between((today - 6.day).beginning_of_day, today.at_end_of_day, n)
    when 'this_month' then date_in_between(today.at_beginning_of_month.beginning_of_day,
                              today.at_end_of_month.end_of_day, n)
    when 'last_30_days' then date_in_between((today - 29.day).beginning_of_day, today.at_end_of_day, n)
    when 'from_to' then date_in_between((Date.parse(cond[:from]) rescue nil), (Date.parse(cond[:to]) rescue nil), n)
    end
  end

  def apply_string_condition(replacement_string, value)
     @relation = @relation.where(replacement_string, value) if value.present?
  end

  def apply_like_condition(column, value)
    like ||= Tabulatr::Utility.like_statement
    apply_string_condition("#{column.col_options.filter_sql} #{like} ?", "%#{value}%") if value.present?
  end

  def apply_range_condition(column, hash)
    apply_string_condition("#{column.col_options.filter_sql} >= ?", "#{hash[:from]}")
    apply_string_condition("#{column.col_options.filter_sql} <= ?", "#{hash[:to]}")
  end

  def apply_array_condition(column, value)
    @relation = @relation.where(column.table_name => { column.name => value })
  end

  def apply_custom_filter(filter, value)
    filter_result = filter.block.(@relation, value)
    handle_search_result(filter_result)
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

  def date_in_between(from, to, column)
    @relation = @relation.where("#{column.col_options.filter_sql} >= ?", from) if from.present?
    @relation = @relation.where("#{column.col_options.filter_sql} <= ?", to) if to.present?
  end

  def find_column(name)
    table_name, method_name = name.split(':').map(&:to_sym)
    table_columns.find { |c| c.table_name == table_name && c.name == method_name } ||
      filters.find { |f| f.name.to_sym == name.to_sym }
  end

end

Tabulatr::Data.send :include, Tabulatr::Data::Filtering
