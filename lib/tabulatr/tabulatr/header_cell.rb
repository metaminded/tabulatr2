#--
# Copyright (c) 2010-2011 Peter Horn, Provideal GmbH
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

class Tabulatr


  # the method used to actually define the headers of the columns,
  # taking the name of the attribute and a hash of options.
  #
  # The following options are evaluated here:
  # <tt>:th_html</tt>:: a hash with html-attributes added to the <th>s created
  # <tt>:header</tt>:: if present, the value will be output in the header cell,
  #                    otherwise, the capitalized name is used
  def header_column(name, opts={}, &block)
    raise "Not in header mode!" if @row_mode != :header
    sortparam = "#{@classname}#{@table_form_options[:sort_postfix]}"
    filter_name = "#{@classname}#{@table_form_options[:filter_postfix]}[#{name}]"
    bid = "#{@classname}#{@table_form_options[:sort_postfix]}"

    create_header_tag(name, opts, sortparam, filter_name, name,
      nil, bid
    )
    # opts = normalize_column_options(name, opts)
    # opts = normalize_header_column_options opts
    # opts[:th_html]['data-tabulatr-column-name'] = name
    # opts[:th_html]['data-tabulatr-form-name'] = filter_name
    # opts[:th_html]['data-tabulatr-sorting-name'] = "#{@klass.table_name}.#{name}"
    # make_tag(:th, opts[:th_html]) do
    #   concat(t(opts[:header] || readable_name_for(name)), :escape_html)
    #   create_sorting_elements opts, sortparam, name, bid
    # end # </th>
  end

  # the method used to actually define the headers of the columns,
  # taking the name of the attribute and a hash of options.
  #
  # The following options are evaluated here:
  # <tt>:th_html</tt>:: a hash with html-attributes added to the <th>s created
  # <tt>:header</tt>:: if present, the value will be output in the header cell,
  #                    otherwise, the capitalized name is used
  def header_association(relation, name, opts={}, &block)
    raise "Not in header mode!" if @row_mode != :header
    create_header_tag(name, opts,
      "#{@classname}#{@table_form_options[:sort_postfix]}[#{relation.to_s}.#{name.to_s}]",
      "#{@classname}#{@table_form_options[:filter_postfix]}[#{@table_form_options[:associations_filter]}][#{relation.to_s}.#{name.to_s}]",
      "#{relation}:#{name}",
      relation
    )
  end

  def header_checkbox(opts={}, &block)
    raise "Whatever that's for!" if block_given?
    opts = normalize_column_options(:checkbox_column, opts)
    opts = normalize_header_column_options opts, :checkbox
    make_tag(:th, opts[:th_html]) do
      make_tag(:input, type: 'checkbox', :'data-table' => "#{@klass.to_s.downcase}_table",
        class: "tabulatr_mark_all"){}
      render_batch_actions if @table_options[:batch_actions]
    end
  end

  def header_action(opts={}, &block)
    raise "Please specify a block" unless block_given?
    opts = normalize_column_options(:action_column, opts)
    opts = normalize_header_column_options opts, :action
    dummy = DummyRecord.new()
    opts[:th_html]['data-tabulatr-action'] = yield(dummy).gsub(/"/, "'")
    @attributes = (@attributes + dummy.requested_methods).flatten
    names = dummy.requested_methods.join(',')

    make_tag(:th, opts[:th_html].merge('data-tabulatr-column-name' => names)) do
      concat(t(opts[:header] || ""), :escape_html)
    end
  end

  private

  def normalize_header_column_options opts, type=nil
    opts[:th_html] ||= {}
    opts[:th_html]['data-tabulatr-column-type'] = type if type
    if opts[:format_methods]
      opts[:th_html]['data-tabulatr-methods'] = opts[:format_methods].join(',')
    end
    opts
  end

  def create_sorting_elements opts, sortparam, name, bid=""
    if opts[:sortable] and @table_options[:sortable]
      if @sorting and @sorting[:by].to_s == name.to_s
        pname = "#{sortparam}[_resort][#{name}]"
        bid = "#{bid}_#{name}"
        sort_dir = @sorting[:direction] == 'asc' ? 'desc' : 'asc'
        make_tag(:input, :type => :hidden,
          :name => "#{sortparam}[#{name}][#{@sorting[:direction]}]",
          :value => "#{@sorting[:direction]}")
      else
        pname = "#{sortparam}[_resort][#{name}]"
        bid = "#{bid}_#{name}"
        sort_dir = 'desc'
      end
      make_image_button(:id => bid, :name => pname, :'data-sort' => sort_dir)
    end
  end


  def create_header_tag name, opts, sort_param, filter_name, column_name, relation=nil, bid=nil
    opts = normalize_column_options(name, opts)
    opts = normalize_header_column_options(opts)
    opts[:th_html]['data-tabulatr-column-name'] = column_name
    opts[:th_html]['data-tabulatr-form-name'] = filter_name
    opts[:th_html]['data-tabulatr-sorting-name'] = sorting_name(name, relation)
    make_tag(:th, opts[:th_html]) do
      concat(t(opts[:header] || readable_name_for(name, relation)), :escape_html)
      create_sorting_elements(opts, sort_param, name, bid) unless relation && name.to_sym == :count
    end # </th>
  end

  def sorting_name name, relation=nil
    return "#{@klass.reflect_on_association(relation).table_name}.#{name}" if relation && @klass.reflect_on_association(relation).klass.column_names.include?(name.to_s)
    return "#{@klass.table_name}.#{name}" if @klass.column_names.include?(name.to_s)
    name
  end

end
