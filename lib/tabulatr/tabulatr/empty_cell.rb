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
  def empty_column(name, opts={}, &block)
    raise "Not in empty mode!" if @row_mode != :empty
    opts = normalize_column_options(name, opts)
    make_tag(:td, opts[:filter_html]) do
    end # </td>
  end

private

  # def filter_tag(of, iname, value, opts)
  #   if !of
  #     ""
  #   elsif of.is_a?(Hash) or of.is_a?(Array) or of.is_a?(String)
  #     make_tag(:select, :name => iname, :style => "width:#{opts[:filter_width]}") do
  #       if of.class.is_a?(String)
  #         concat(of)
  #       else
  #         concat("<option></option>")
  #         t = options_for_select(of)
  #         concat(t.sub("value=\"#{value}\"", "value=\"#{value}\" selected=\"selected\""))
  #       end
  #     end # </select>
  #   elsif opts[:filter] == :range
  #     make_tag(:input, :type => :text, :name => "#{iname}[from]",
  #       :style => "width:#{opts[:filter_width]}",
  #       :value => value ? value[:from] : '')
  #     concat(t(opts[:range_filter_symbol]))
  #     make_tag(:input, :type => :text, :name => "#{iname}[to]",
  #       :style => "width:#{opts[:filter_width]}",
  #       :value => value ? value[:to] : '')
  #   elsif opts[:filter] == :checkbox
  #     checkbox_value = opts[:checkbox_value]
  #     checkbox_label = opts[:checkbox_label]
  #     concat(check_box_tag(iname, checkbox_value, false, {}))
  #     concat(checkbox_label)
  #   elsif opts[:filter] == :like
  #     make_tag(:input, :type => :text, :name => "#{iname}[like]",
  #       :style => "width:#{opts[:filter_width]}",
  #       :value => value ? value[:like] : '')
  #   else
  #     make_tag(:input, :type => :text, :name => "#{iname}", :style => "width:#{opts[:filter_width]}",
  #       :value => value)
  #   end # if
  # end

end
