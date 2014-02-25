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

class Tabulatr::Renderer

  def initialize(klass, view,
      filter: true,          # false for no filter row at all
      search: true,          # show fuzzy search field
      paginate: false,       # true to show paginator
      pagesize: 20,          # default pagesize
      sortable: true,        # true to allow sorting (can be specified for every sortable column)
      batch_actions: false,  # :name => value hash of batch action stuff
      footer_content: false, # if given, add a <%= content_for <footer_content> %> before the </table>
      path: '#',             # where to send the AJAX-requests to
      order_by: nil,
      html_class: '')         # default order
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
      html_class: 'table tabulatr_table '.concat(html_class)
    }
    @classname = @klass.name.underscore
  end

  def build_table(columns, &block)
    tdc = "#{@klass.name}TabulatrData".constantize.new(@klass)
    if block_given?
      @columns = ColumnsFromBlock.process @klass, &block
    elsif columns.any?
      @columns = get_requested_columns(tdc.table_columns, columns)
    else
      @columns = tdc.table_columns
    end

    @view.render(partial: '/tabulatr/tabulatr_table', locals: {
      columns: @columns,
      table_options: @table_options,
      klass: @klass,
      classname: @classname,
      tabulatr_data: tdc,
      table_id: generate_id,
      formatted_name: formatted_name
    })
  end

  def build_static_table(records, &block)
    @columns = ColumnsFromBlock.process @klass, &block

    @view.render(partial: '/tabulatr/tabulatr_static_table', locals: {
      columns: @columns,
      table_options: @table_options,
      klass: @klass,
      classname: @classname,
      records: records
    })
  end

  def generate_id
    "#{formatted_name}_table_#{SecureRandom.uuid}"
  end

  def formatted_name
    "#{@klass.to_s.gsub(/::/, '--').downcase}"
  end

  def self.build_static_table(records, view, toptions={}, &block)
    return '' unless records.present?
    klass = records.first.class
    new(klass, view, toptions).build_static_table(records, &block)
  end

  def self.build_table(klass, view, toptions={}, columns, &block)
    new(klass, view, toptions).build_table(columns, &block)
  end

  private

  def get_requested_columns(available_columns, requested_columns)
    requested_columns.collect do |r|
      r = "#{r.keys.first}:#{r.values.first}" if r.is_a?(Hash) && r.count == 1
      available_columns.select{|column| column.full_name.to_sym == r.to_sym }
    end.flatten
  end

end

require_relative './column'
require_relative './association'
require_relative './action'
require_relative './checkbox'
require_relative './columns_from_block'

