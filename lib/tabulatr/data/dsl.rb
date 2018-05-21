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

  def main_class
    target_class_name # to get auto setting @target_class
    @target_class
  end

  def column(name, opts = {}, &block)
    @table_columns ||= []
    sql_options = determine_sql(opts, main_class.quoted_table_name, name)
    opts = {
            sort_sql: sql_options[:sort_sql],
            filter: true,
            sortable: true,
            filter_sql: sql_options[:filter_sql]}.merge(opts)
    table_column = Tabulatr::Renderer::Column.from(
        name: name,
        klass: @base,
        col_options: Tabulatr::ParamsBuilder.new(opts),
        table_name: main_class.table_name.to_sym,
        output: block_given? ? block : ->(record){record.send(name)})
    @table_columns << table_column
  end

  def association(assoc, name, opts = {}, &block)
    @table_columns ||= []
    unless assoc.is_a?(Array)
      assoc = assoc.to_s.split('-').map(&:to_sym)
    end
    assoc_klass = assoc.reduce(main_class) { |c,a| c.reflect_on_association(a.to_sym).try(:klass) }
    sql_options = determine_sql(opts, assoc_klass.try(:quoted_table_name), name)
    opts = {
        sort_sql: sql_options[:sort_sql],
        filter_sql: sql_options[:filter_sql]}.merge(opts)
    table_column = Tabulatr::Renderer::Association.from(
        name: name,
        klass: assoc_klass,
        col_options: Tabulatr::ParamsBuilder.new(opts),
        table_name: assoc.join('-').to_sym,
        output: block_given? ? block : lambda do |record|
          a = assoc.reduce(record) {|cur,nxt| cur.try(:send, nxt)}
          a.try(:read_attribute, name) || a.try(name)
        end)
    @table_columns << table_column
  end

  def actions(opts = {}, &block)
    raise 'give a block to action column' unless block_given?
    @table_columns ||= []
    table_column = Tabulatr::Renderer::Action.from(
      name: '_actions',
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
      self.controller.render_to_string partial: '/tabulatr/tabulatr_buttons', locals: {buttons: tdbb.val}, formats: [:html]
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

  private

  def target_class(name)
    s = name.to_s
    @target_class = s.camelize.constantize rescue "There's no class `#{s.camelize}' for `#{self.name}'"
    @target_class_name = s.underscore
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

  def determine_sql(options, table_name, column_name)
    options_hash = {}
    [:sort_sql, :filter_sql].each do |sym|
      options_hash[sym] = options[sym] || options[:sql] || "#{table_name}.#{ActiveRecord::Base.connection.quote_column_name(column_name)}"
    end
    options_hash
  end
end

Tabulatr::Data.send :extend, Tabulatr::Data::DSL
