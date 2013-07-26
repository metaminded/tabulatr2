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
    bid = "#{@classname}#{@table_form_options[:sort_postfix]}"
    filter_name = "#{@classname}#{@table_form_options[:filter_postfix]}[#{name}]"
    opts = normalize_column_options(name, opts)
    opts = normalize_header_column_options opts
    opts[:th_html]['data-tabulatr-column-name'] = name
    opts[:th_html]['data-tabulatr-form-name'] = filter_name
    make_tag(:th, opts[:th_html]) do
      concat(t(opts[:header] || @klass.human_attribute_name(name).titlecase), :escape_html)
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
    end # </th>
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
    opts = normalize_column_options(name, opts)
    opts = normalize_header_column_options(opts)

    filter_name = "#{@classname}#{@table_form_options[:filter_postfix]}[#{@table_form_options[:associations_filter]}][#{relation.to_s}.#{name.to_s}]"
    if opts[:format_method]
      opts[:th_html]['data-tabulatr-format-method'] = opts[:format_method]
    end
    opts[:th_html]['data-tabulatr-form-name'] = filter_name
    opts[:th_html]['data-tabulatr-column-name'] = "#{relation}:#{name}"
    make_tag(:th, opts[:th_html]) do
      concat(t(opts[:header] || "#{relation.to_s.humanize.titlecase} #{name.to_s.humanize.titlecase}"), :escape_html)
    end # </th>
  end

  def header_checkbox(opts={}, &block)
    raise "Whatever that's for!" if block_given?
    opts = normalize_column_options(:checkbox_column, opts)
    opts = normalize_header_column_options opts, :checkbox
    make_tag(:th, opts[:th_html]) do
      make_tag(:input, type: 'checkbox', id: 'tabulatr_mark_all'){}
      render_batch_actions if @table_options[:batch_actions]
    end
  end

  def header_action(opts={}, &block)
    raise "Please specify a block" unless block_given?
    opts = normalize_column_options(:action_column, opts)
    opts = normalize_header_column_options opts, :action
    opts[:th_html]['data-tabulatr-action'] = yield(DummyRecord.new).gsub!(/"/, "")
    make_tag(:th, opts[:th_html]) do
      concat(t(opts[:header] || ""), :escape_html)
    end
  end

  private

  def normalize_header_column_options opts, type=nil
    unless opts[:th_html]
      opts[:th_html] = {}
    end
    opts[:th_html]['data-tabulatr-column-type'] = type if type
    if opts[:format_method]
      opts[:th_html]['data-tabulatr-format-method'] = opts[:format_method]
    end
    opts
  end

end
