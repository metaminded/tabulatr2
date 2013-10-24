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
      nn = build_column_name(att, table_name: table_name, assoc_name: assoc, use_for: :filter)
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
      elsif v[:date].present?
        apply_date_condition(n, v[:date])
      else
        @relation = @relation.where("#{n} >= ?", "#{v[:from]}") if v[:from].present?
        @relation = @relation.where("#{n} <= ?", "#{v[:to]}") if v[:to].present?
      end
    else
      raise "Wrong filter type: #{v.class}"
    end
  end

  def apply_date_condition(n, cond)
    today = Date.today
    case cond[:simple]
    when 'none' then return
    when 'today' then since = today
    when 'yesterday' then since = today - 1.day
    when 'this_week' then since = today.at_beginning_of_week
    when 'last_7_days' then since = today - 7.day
    when 'this_month' then since = today.at_beginning_of_month
    when 'last_30_days' then since = today. - 30.day
    when 'from_to'
      since = Date.parse(cond[:from]) if cond[:from].present?
      @relation = @relation.where("#{n} <= ?", Date.parse(cond[:to])) if cond[:to].present?
    end
    @relation = @relation.where("#{n} >= ?", since) if since.present?
  end

end

Tabulatr::Data.send :include, Tabulatr::Data::Filtering
