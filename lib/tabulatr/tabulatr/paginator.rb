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
    pagination_name = "#{@classname}#{TABLE_FORM_OPTIONS[:pagination_postfix]}"

    if (@table_options[:paginate].is_a?(Fixnum)) && @klass.count > @table_options[:paginate] ||
      @table_options[:paginate] === true
      # render the 'wrapping' div
      make_tag(:div, :class => @table_options[:paginator_div_class]) do
        make_tag(:ul){}
      end # </div>
    end
    make_tag(:div, :class => 'btn-group tabulatr-per-page') do
      make_tag(:button, :class => 'btn') do
        concat(I18n.t('tabulatr.rows_per_page'))
      end
      make_tag(:button, :class => 'btn dropdown-toggle', :'data-toggle' => 'dropdown') do
        make_tag(:span, :class => 'caret'){}
      end
      make_tag(:ul, :class => 'dropdown-menu') do
        make_tag(:li) do
          make_tag(:a, :href => "javascript: void(0);", :'data-items-per-page' => 10) do
            concat('10')
          end
        end
        make_tag(:li) do
          make_tag(:a, :href => "javascript: void(0);", :'data-items-per-page' => 25) do
            concat('25')
          end
        end
        make_tag(:li) do
          make_tag(:a, :href => "javascript: void(0);", :'data-items-per-page' => 50) do
            concat('50')
          end
        end
        make_tag(:li) do
          make_tag(:a, :href => "javascript: void(0);", :'data-items-per-page' => 100) do
            concat('100')
          end
        end
      end
    end
  end

end
