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

class Tabulatr::Renderer

  def initialize(klass, view,
      filter:              Tabulatr.filter,
      search:              Tabulatr.search,
      paginate:            Tabulatr.paginate,
      pagesize:            Tabulatr.pagesize,
      sortable:            Tabulatr.sortable,
      batch_actions:       Tabulatr.batch_actions,
      footer_content:      Tabulatr.footer_content,
      path:                Tabulatr.path,
      order_by:            Tabulatr.order_by,
      html_class:          Tabulatr.html_class,
      pagination_position: Tabulatr.pagination_position,
      counter_position:    Tabulatr.counter_position,
      persistent:          Tabulatr.persistent)
    @klass = klass
    @view = view
    @table_options = {
      filter: filter,
      search: search,
      paginate: paginate,
      pagesize: pagesize,
      sortable: sortable,
      batch_actions: batch_actions,
      footer_content: footer_content,
      path: path,
      order_by: order_by,
      html_class: 'table tabulatr_table '.concat(html_class),
      pagination_position: pagination_position,
      counter_position: counter_position,
      persistent: paginate ? persistent : false
    }
    @classname = @klass.name.underscore
  end

  def build_table(columns, filters, tabulatr_data_class, &block)
    tdc = get_data_class(tabulatr_data_class)
    set_columns_and_filters(tdc, columns, filters, &block)
    @view.render(partial: '/tabulatr/tabulatr_table', locals: {
      columns: @columns,
      table_options: @table_options,
      klass: @klass,
      classname: @classname,
      tabulatr_data: tdc,
      table_id: generate_id,
      formatted_name: Tabulatr::Utility.formatted_name(@klass.name),
      filter: tdc.filters || []
    })
  end

  def build_static_table(records, &block)
    @columns = ColumnsFromBlock.process(@klass, &block).columns

    @view.render(partial: '/tabulatr/tabulatr_static_table', locals: {
      columns: @columns,
      table_options: @table_options,
      klass: @klass,
      classname: @classname,
      records: records
    })
  end

  def generate_id
    "#{Tabulatr::Utility.formatted_name(@klass.name)}_table_#{@view.controller.controller_name}_#{@view.controller.action_name}_#{@view.instance_variable_get(:@_tabulatr_table_index)}"
  end

  def self.build_static_table(records, view, toptions={}, &block)
    return '' unless records.present?
    klass = records.first.class
    new(klass, view, toptions).build_static_table(records, &block)
  end

  def self.build_table(klass, view, toptions={}, columns, filters, tabulatr_data_class, &block)
    new(klass, view, toptions).build_table(columns, filters, tabulatr_data_class, &block)
  end

  private

  def get_requested_columns(available_columns, requested_columns)
    main_table_name = @klass.table_name.to_sym
    requested_columns.collect do |r|
      if r.is_a?(Hash) && r.count == 1
        r = "#{r.keys.first}:#{r.values.first}"
      end
      result = available_columns.find{|column| column.full_name.to_sym == r.to_sym }
      result ||= available_columns.find{|column| column.name.to_sym == r.to_sym && column.table_name == main_table_name}
      result or raise "Can't find column '#{r}'"
    end.flatten
  end

  def get_requested_filters(available_filters, requested_filters)
    requested_filters.collect do |f|
      available_filters.find("Can't find filter '#{f}'") do |filter|
        filter.name.to_sym == f.to_sym
      end
    end.flatten
  end

  def get_data_class(name = '')
    if name.present?
      name.constantize.new(@klass)
    else
      "#{@klass.name}TabulatrData".constantize.new(@klass)
    end
  end

  def set_columns_and_filters(data_class, columns, filters, &block)
    if block_given?
      @columns = ColumnsFromBlock.process(@klass, data_class, &block).columns
    elsif columns.any?
      @columns = get_requested_columns(data_class.table_columns, columns)
    else
      @columns = data_class.table_columns
    end
    if filters && filters.any?
      @filters = get_requested_filters(data_class.filters, filters)
    end
  end

end

require_relative './column'
require_relative './association'
require_relative './action'
require_relative './buttons'
require_relative './checkbox'
require_relative './columns_from_block'
require_relative './filter'
