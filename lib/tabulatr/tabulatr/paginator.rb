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

  #render the paginator controls, inputs etc.
  def render_paginator
    # get the current pagination state
    if (@table_options[:paginate].is_a?(Fixnum)) && @klass.count > @table_options[:paginate] ||
      @table_options[:paginate] === true
      send(Tabulatr.bootstrap_paginator)
    end
    make_tag(:div, :class => 'btn-group tabulatr-per-page', :'data-table' => "#{@klass.to_s.downcase}_table") do
      make_tag(:button, :class => 'btn') do
        concat(I18n.t('tabulatr.rows_per_page'))
      end
      make_tag(:button, :class => 'btn dropdown-toggle', :'data-toggle' => 'dropdown') do
        make_tag(:span, :class => 'caret'){}
      end
      make_tag(:ul, :class => 'dropdown-menu') do
        [10, 25, 50, 100].push(@table_options[:default_pagesize]).uniq.sort.each do |n|
          create_pagination_select(n, n == @table_options[:default_pagesize])
        end
      end
    end
  end

  def create_pagination_select n, default=false
    make_tag(:li) do
      params = { :href => "javascript: void(0);",
                 :'data-items-per-page' => n }
      params[:class] = 'active' if default
      make_tag(:a, params) do
        concat(n)
      end
    end
  end

  private

  # bootstrap 3
  def create_ul_paginator
    make_tag(:ul, :class => @table_options[:paginator_div_class],
      :'data-table' => "#{@klass.to_s.downcase}_table") do
    end
  end

  # bootstrap 2
  def create_div_paginator
    make_tag(:div, :class => @table_options[:paginator_div_class],
      :'data-table' => "#{@klass.to_s.downcase}_table") do
      make_tag(:ul){}
    end
  end

end
