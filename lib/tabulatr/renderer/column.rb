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

class Tabulatr::Renderer::Column
  include ActiveModel::Model

  attr_accessor *%i{name header width align valign wrap type th_html filter_html
    filter checkbox_value checkbox_label filter_width range_filter_symbol
    sortable table_name block klass format map classes cell_style header_style}

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
    filter: true,
    checkbox_value: '1',
    checkbox_label: '',
    sortable: true,
    format: nil,
    map: true,
    klass: nil,
    cell_style: {},
    header_style: {},
    &block)
    b = block_given? ? block : nil
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
      filter: filter,
      checkbox_value: checkbox_value,
      checkbox_label: checkbox_label,
      sortable: sortable,
      format: format,
      map: map,
      klass: klass,
      block: b,
      cell_style: cell_style,
      header_style: header_style
    ).apply_styles!
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
    self.cell_style = style_options.merge(self.cell_style).map{|e| e.join(':')}.join(';')
    self.header_style = style_options.merge(self.header_style).map{|e| e.join(':')}.join(';')
    self
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
    if block
      return view.instance_exec(record, &block)
    end
    val = principal_value(record) or return ''

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

  def principal_value(record)
    record.send name
  end

end
