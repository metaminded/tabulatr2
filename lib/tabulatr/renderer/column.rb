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

class Tabulatr::Renderer::Column
  include ActiveModel::Model

  attr_accessor *%i{name header width align valign wrap type th_html filter_html
    filter_label filter filter_width range_filter_symbol
    sortable table_name block klass format map classes cell_style header_style
    sort_sql filter_sql output}

  def self.from(
    name: nil,
    table_name: nil,
    header: nil,
    classes: nil,
    width: false,
    align: false,
    valign: false,
    wrap: nil,
    th_html: false,
    filter_html: false,
    filter_label: nil,
    filter: true,
    sortable: true,
    format: nil,
    map: true,
    klass: nil,
    cell_style: {},
    header_style: {},
    sort_sql: nil,
    filter_sql: nil,
    output: nil,
    &block)
    self.new(
      name: name,
      table_name: table_name,
      header: header,
      classes: classes,
      width: width,
      align: align,
      valign: valign,
      wrap: wrap,
      th_html: th_html,
      filter_html: filter_html,
      filter_label: filter_label,
      filter: filter,
      sortable: sortable,
      format: format,
      map: map,
      klass: klass,
      block: block,
      cell_style: cell_style,
      header_style: header_style,
      sort_sql: sort_sql,
      filter_sql: filter_sql,
      output: output
    ).apply_styles!
  end

  def update_options(hash = {}, &block)
    self.header = hash[:header] || self.header
    self.classes = hash[:classes] || self.classes
    self.width = hash[:width] || self.width
    self.align = hash[:align] || self.align
    self.valign = hash[:valign] || self.valign
    self.wrap = hash[:wrap] || self.wrap
    self.th_html = hash[:th_html] || self.th_html
    self.filter_html = hash[:filter_html] || self.filter_html
    self.filter_label = hash[:filter_label] || self.filter_label
    self.filter = hash[:filter] || self.filter
    self.sortable = hash[:sortable] || self.sortable
    self.format = hash[:format] || self.format
    self.map = hash[:map] || self.map
    self.th_html = hash[:th_html] || self.th_html
    self.output = block if block_given?
    self.filter_sql = hash[:filter_sql] || self.filter_sql
    self.sort_sql = hash[:sort_sql] || self.sort_sql
    if self.cell_style == ''
      self.cell_style = {}
    end
    self.cell_style = hash[:cell_style] || self.cell_style
    if self.header_style == ''
      self.header_style = {}
    end
    self.header_style = hash[:header_style] || self.header_style
    self.apply_styles!
  end

  def klassname() @_klassname ||= @klass.name.underscore end
  def human_name() header || klass.human_attribute_name(name) end
  def sort_param() "#{klassname}_sort" end
  def full_name() [table_name, name].compact.join(":") end
  def coltype() 'column' end

  def column?() true end
  def association?() false end
  def checkbox?() false end
  def action?() false end

  def apply_styles!
    # raise cell_style.inspect
    self.cell_style = style_options.merge(self.cell_style)
    self.header_style = style_options.merge(self.header_style)
    self
  end

  def html_cell_style
    cell_style.map{|e| e.join(':')}.join(';')
  end

  def html_header_style
    header_style.map{|e| e.join(':')}.join(';')
  end

  def style_options
    default_style_attributes = {
      :'text-align' => align,
      width: width,
      :'vertical-align' => valign,
      :'white-space' => wrap
    }.select{|k,v| v}

    default_style_attributes || {}
  end

  def value_for(record, view)
    val = principal_value(record, view)
    if format.present? && val.respond_to?(:to_ary)
      val.map do |v|
        case format
        when Symbol then view.send(format, v)
        when String then format % v
        when Proc   then format.(v)
        else val
        end
      end
    elsif format.present?
      case format
      when Symbol then view.send(format, val)
      when String then format % val
      when Proc   then format.(val)
      else val
      end
    else
      val
    end
  end

  def principal_value(record, view)
    if output
      view.instance_exec(record, &output)
    elsif block
      view.instance_exec(record, &block)
    elsif name
      record.send name
    else
      nil
    end
  end

  def determine_appropriate_filter!
    case self.klass.columns_hash[self.name.to_s].try(:type)
    when :integer, :float, :decimal
      if self.klass.respond_to?(:defined_enums) && self.klass.defined_enums.keys.include?(self.name.to_s)
        self.filter = :enum
      else
        self.filter = :exact
      end
    when :string, :text
      self.filter = :like
    when :date, :time, :datetime, :timestamp
      self.filter = :date
    when :boolean
      self.filter = :checkbox
    end
  end

end
