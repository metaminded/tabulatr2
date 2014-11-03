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

module Tabulatr::Data::DSL

  def target_class(name)
    s = name.to_s
    @target_class = s.camelize.constantize rescue "There's no class `#{s.camelize}' for `#{self.name}'"
    @target_class_name = s.underscore
  end

  def main_class
    target_class_name # to get auto setting @target_class
    @target_class
  end

  def target_class_name
    return @target_class_name if @target_class_name.present?
    if (s = /(.+)TabulatrData\Z/.match(self.name))
      # try whether it's a class
      target_class s[1].underscore
    else
      raise "Don't know which class should be target_class for `#{self.name}'."
    end
  end

  def column(name, header: nil, sort_sql: nil, filter_sql: nil, sql: nil, table_column_options: {},
    classes: nil, width: false, align: false, valign: false, wrap: nil, th_html: false,
    filter_html: false, filter: true, sortable: true, format: nil, map: true, cell_style: {},
    header_style: {},
    &block)
    @table_columns ||= []
    table_column_options = {classes: classes, width: width, align: align, valign: valign, wrap: wrap,
      th_html: th_html, filter_html: filter_html, filter: filter, sortable: sortable,
      format: format, map: map, cell_style: cell_style, header_style: header_style,
      header: header
    }.merge(table_column_options)
    table_name = main_class.table_name
    table_column = Tabulatr::Renderer::Column.from(
      table_column_options.merge(name: name,
        klass: @base,
        sort_sql: sort_sql || sql || name,
        filter_sql: filter_sql || sql || name,
        table_name: table_name.to_sym,
        output: block_given? ? block : ->(record){record.send(name)}))
    @table_columns << table_column
  end

  def association(assoc, name, header: nil, sort_sql: nil, filter_sql: nil, sql: nil, table_column_options: {},
    classes: nil, width: false, align: false, valign: false, wrap: nil, th_html: false,
    filter_html: false, filter: true, sortable: true, format: nil, map: true, cell_style: {},
    header_style: {},
    &block)
    @table_columns ||= []
    table_column_options = {classes: classes, width: width, align: align, valign: valign, wrap: wrap,
      th_html: th_html, filter_html: filter_html, filter: filter, sortable: sortable,
      format: format, map: map, cell_style: cell_style, header_style: header_style,
      header: header
    }.merge(table_column_options)
    assoc_klass = main_class.reflect_on_association(assoc.to_sym)
    t_name = assoc_klass.try(:table_name)
    table_column = Tabulatr::Renderer::Association.from(
      table_column_options.merge(name: name, table_name: assoc,
        klass: assoc_klass.try(:klass),
        sort_sql: sort_sql || sql || name,
        filter_sql: filter_sql || sql || name,
    @table_columns << table_column
  end

  def actions(header: nil, name: nil, table_column_options: {},
    classes: nil, width: false, align: false, valign: false, wrap: nil, th_html: false,
    filter_html: false, filter: true, sortable: true, format: nil, map: true, cell_style: {},
    header_style: {},
    &block)
    raise 'give a block to action column' unless block_given?
    @table_columns ||= []
    table_column_options = {classes: classes, width: width, align: align, valign: valign, wrap: wrap,
      th_html: th_html, filter_html: filter_html, filter: filter, sortable: sortable,
      format: format, map: map, cell_style: cell_style, header_style: header_style
    }.merge(table_column_options)
    table_column = Tabulatr::Renderer::Action.from(
      table_column_options.merge(
        name: (name || '_actions'), table_name: main_class.table_name.to_sym,
        klass: @base, header: header || '',
        filter: false, sortable: false,
        output: block))
    @table_columns << table_column
  end

  def buttons(header: nil, name: nil, table_column_options: {},
    classes: nil, width: false, align: false, valign: false, wrap: nil, th_html: false,
    filter_html: false, filter: true, sortable: true, format: nil, map: true, cell_style: {},
    header_style: {},
    &block)
    raise 'give a block to action column' unless block_given?
    @table_columns ||= []
    table_column_options = {classes: classes, width: width, align: align, valign: valign, wrap: wrap,
      th_html: th_html, filter_html: filter_html, filter: filter, sortable: sortable,
      format: format, map: map, cell_style: cell_style, header_style: header_style
    }.merge(table_column_options)
    output = ->(r) {
      tdbb = Tabulatr::Data::ButtonBuilder.new
      self.instance_exec tdbb, r, &block
      bb = tdbb.val
      self.controller.render_to_string partial: '/tabulatr/tabulatr_buttons', locals: {buttons: bb}, formats: [:html]
    }
    table_column = Tabulatr::Renderer::Buttons.from(
      table_column_options = table_column_options.merge(
        name: (name || '_buttons'), table_name: main_class.table_name.to_sym,
        klass: @base, header: header || '',
        filter: false, sortable: false,
        output: output))
    @table_columns << table_column
  end

  def checkbox(table_column_options: {},
    classes: nil, width: false, align: false, valign: false, wrap: nil, th_html: false,
    filter_html: false, filter: true, sortable: true, format: nil, map: true, cell_style: {},
    header_style: {})
    @table_columns ||= []
    table_column_options = {classes: classes, width: width, align: align, valign: valign, wrap: wrap,
      th_html: th_html, filter_html: filter_html, filter: filter, sortable: sortable,
      format: format, map: map, cell_style: cell_style, header_style: header_style
    }.merge(table_column_options)
    box = Tabulatr::Renderer::Checkbox.from(table_column_options = table_column_options.merge(klass: @base, filter: false, sortable: false))
    @table_columns << box
  end

  def search(*args, &block)
    raise "either column or block" if args.present? && block_given?
    @search = args.presence || block
  end

  def row &block
    raise 'Please pass a block to row if you want to use it.' unless block_given?
    @row = block
  end

end

Tabulatr::Data.send :extend, Tabulatr::Data::DSL
