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

  # the method used to actually define the filters of the columns,
  # taking the name of the attribute and a hash of options.
  #
  # The following options are evaluated here:
  # <tt>:filter_html</tt>:: a hash with html-attributes added to the <ts>s created
  # <tt>:filter</tt>:: may take different values:
  #                    <tt>false</tt>:: no filter is output for this column
  #                    a container:: the keys of the hash are used to define a <tt>select</tt>
  #                             where the values are the <tt>value</tt> of the <tt>options</tt>.
  #                    an Array:: the elements of that array are used to define a
  #                               <tt>select</tt>
  #                    a String:: a <tt>select</tt> is created with that String as options
  #                               you can use ActionView#collection_select and the like
  def filter_column(name, opts={}, &block)
    raise "Not in filter mode!" if @row_mode != :filter
    opts = normalize_column_options(name, opts)
    of = opts[:filter]
    iname = "#{@classname}#{@table_form_options[:filter_postfix]}[#{name}]"
    filter_name = "tabulatr_form_#{name}"
    build_filter(of, filter_name, name, iname, opts) if filterable?(of, name.to_s)
  end

  # the method used to actually define the filters of the columns,
  # taking the name of the attribute and a hash of options.
  #
  # The following options are evaluated here:
  # <tt>:filter_html</tt>:: a hash with html-attributes added to the <ts>s created
  # <tt>:filter</tt>:: may take different values:
  #                    <tt>false</tt>:: no filter is output for this column
  #                    a Hash:: the keys of the hash are used to define a <tt>select</tt>
  #                             where the values are the <tt>value</tt> of the <tt>options</tt>.
  #                    an Array:: the elements of that array are used to define a
  #                               <tt>select</tt>
  #                    a subclass of <tt>ActiveRecord::Base</tt>:: a <tt>select</tt> is created
  #                                                                with all instances
  def filter_association(relation, name, opts={}, &block)
    raise "Not in filter mode!" if @row_mode != :filter
    opts = normalize_column_options(name, opts)

    of = opts[:filter]
    iname = "#{@classname}#{@table_form_options[:filter_postfix]}[#{@table_form_options[:associations_filter]}][#{relation}.#{name}]"
    filter_name = "tabulatr_form_#{relation}_#{name}"
    build_filter(of, filter_name, name, iname, opts, relation) if filterable?(of, name.to_s, relation)
  end

  def filter_checkbox(opts={}, &block)
    raise "Whatever that's for!" if block_given?
    make_tag(:td, opts[:filter_html]) {}
  end

  def filter_action(opts={}, &block)
    raise "Not in filter mode!" if @row_mode != :filter
    opts = normalize_column_options(:action_column, opts)
    make_tag(:td, opts[:filter_html]) do
      concat(t(opts[:filter])) unless [true, false, nil].member?(opts[:filter])
    end # </td>
  end

private

  def filter_tag(of, name, iname, attr_name, opts)
    if !of
      ""
    elsif of.is_a?(Hash) or of.is_a?(Array) or of.is_a?(String)
      make_tag(:select, :style => "width:#{opts[:filter_width]}",
        :id => name, name: iname) do
        if of.class.is_a?(String)
          concat(of)
        else
          concat("<option></option>")
          t = options_for_select(of)
          concat(t.sub("value=\"\"", "value=\"\" selected=\"selected\""))
        end
      end # </select>
    elsif opts[:filter] == :range
      filter_text_tag(opts[:filter_width], name, iname, attr_name, 'from')
      concat(t(opts[:range_filter_symbol]))
      filter_text_tag(opts[:filter_width], name, iname, attr_name, 'to')
    elsif opts[:filter] == :checkbox
      checkbox_value = opts[:checkbox_value]
      checkbox_label = opts[:checkbox_label]
      concat(check_box_tag(iname, checkbox_value, false, {}))
      concat(checkbox_label)
    elsif opts[:filter] == :exact
      filter_text_tag(opts[:filter_width], name, iname, attr_name, 'normal')
    else
      filter_text_tag(opts[:filter_width], name, iname, attr_name, 'like')
    end # if
  end

  def filter_text_tag width, name, iname, attr_name, type=nil
    name_attribute = iname
    name_attribute += "[#{type}]" if type && type != 'normal'
    make_tag(:input, :type => :text, :id => name,
        :style => "width:#{width}",
        :value => '',
        :'data-type' => type,
        :'data-tabulatr-attribute' => attr_name,
        :class => 'tabulatr_filter',
        :name => name_attribute)
  end

  def build_filter(of, filter_name, name, iname, opts, relation=nil)
    if of
      make_tag(:div, class: 'control-group') do
        make_tag(:label, class: 'control-label', for: filter_name) do
          concat(t(opts[:header] || readable_name_for(name, relation)), :escape_html)
        end
        make_tag(:div, class: 'controls') do
          filter_tag(of, filter_name, iname, name, opts)
        end
      end
    end
  end

  def filterable?(of, name, relation=nil)
    of &&
    ((@klass.column_names.include?(name) && !relation) ||
      (relation &&
       @klass.reflect_on_association(relation).klass.column_names.include?(name)))
  end

end
