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

  def column(name, opts = {}, &block)
    @table_columns ||= []
    table_name = main_class.table_name
    opts = {sort_sql: opts[:sort_sql] || opts[:sql] || "#{main_class.quoted_table_name}.#{ActiveRecord::Base.connection.quote_column_name(name)}",
            filter: true,
            sortable: true,
        filter_sql: opts[:filter_sql] || opts[:sql] || "#{main_class.quoted_table_name}.#{ActiveRecord::Base.connection.quote_column_name(name)}"}.merge(opts)
    col_options = Tabulatr::ParamsBuilder.new(opts)
    table_column = Tabulatr::Renderer::Column.from(
        name: name,
        klass: @base,
        col_options: col_options,
        table_name: table_name.to_sym,
        output: block_given? ? block : ->(record){record.send(name)})
    @table_columns << table_column
  end

  def association(assoc, name, opts = {}, &block)
    @table_columns ||= []
    assoc_klass = main_class.reflect_on_association(assoc.to_sym)
    t_name = assoc_klass.try(:quoted_table_name)
    opts = {sort_sql: opts[:sort_sql] || opts[:sql] || "#{t_name}.#{ActiveRecord::Base.connection.quote_column_name(name)}",
        filter_sql: opts[:filter_sql] || opts[:sql] || "#{t_name}.#{ActiveRecord::Base.connection.quote_column_name(name)}"}.merge(opts)
    col_options = Tabulatr::ParamsBuilder.new(opts)
    table_column = Tabulatr::Renderer::Association.from(
        name: name,
        klass: assoc_klass.try(:klass),
        col_options: col_options,
        table_name: assoc,
        output: block_given? ? block : ->(record){a=record.send(assoc); a.try(:read_attribute, name) || a.try(name)})
    @table_columns << table_column
  end

  def actions(opts = {}, &block)
    raise 'give a block to action column' unless block_given?
    @table_columns ||= []
    table_column = Tabulatr::Renderer::Action.from(
      name: (name || '_actions'),
      table_name: main_class.table_name.to_sym,
      klass: @base,
      col_options: Tabulatr::ParamsBuilder.new({header: (opts[:header] || ''), filter: false, sortable: false}),
      output: block)
    @table_columns << table_column
  end

  def buttons(opts = {}, &block)
    raise 'give a block to action column' unless block_given?
    @table_columns ||= []
    output = ->(r) {
      tdbb = Tabulatr::Data::ButtonBuilder.new
      self.instance_exec tdbb, r, &block
      bb = tdbb.val
      self.controller.render_to_string partial: '/tabulatr/tabulatr_buttons', locals: {buttons: bb}, formats: [:html]
    }
    opts = {header: opts[:header] || '', filter: false, sortable: false}.merge(opts)
    table_column = Tabulatr::Renderer::Buttons.from(
      name: (opts[:name] || '_buttons'),
      table_name: main_class.table_name.to_sym,
      klass: @base,
      col_options: Tabulatr::ParamsBuilder.new(opts),
      output: output)
    @table_columns << table_column
  end

  def checkbox(opts = {})
    @table_columns ||= []
    box = Tabulatr::Renderer::Checkbox.from(klass: @base,
            col_options: Tabulatr::ParamsBuilder.new(opts.merge(filter: false, sortable: false)))
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

  def filter(name, partial: nil, &block)
    @filters ||= []
    @filters << Tabulatr::Renderer::Filter.new(name, partial: partial, &block)
  end

end

Tabulatr::Data.send :extend, Tabulatr::Data::DSL
