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
    pparams = @records.__pagination
    page = pparams[:page].to_i
    pages = pparams[:pages].to_i
    pagesize = pparams[:pagesize].to_i
    pagesizes = pparams[:pagesizes].map &:to_i

    if (@table_options[:paginate].is_a?(Fixnum) && @table_options[:paginate] < pages) ||
      @table_options[:paginate] === true
      # render the 'wrapping' div
      make_tag(:div, :class => @table_options[:paginator_div_class]) do
        make_tag(:ul) do
          if pages < 13
            (1..pages).each do |p|
              make_tag(:li, class: (page == p ? 'active' : '')) do
                make_tag(:a, href: '#', :'data-page' => p) do
                  concat(p)
                end
              end
            end
          else
            if page > 1
              make_tag(:li) do
                make_tag(:a, href: '#', :'data-page' => 1) do
                  concat(1)
                end
              end
            end

            between = (1 + page) / 2

            if between > 1 && between < page - 2
              make_tag(:li) do
                make_tag(:span) do
                  concat('...')
                end
              end
              make_tag(:li) do
                make_tag(:a, href: '#', :'data-page' => between) do
                  concat(between)
                end
              end
            end

            if page > 4
              make_tag(:li) do
                make_tag(:span) do
                  concat('...')
                end
              end
            end

            if page > 3
              make_tag(:li) do
                make_tag(:a, href: '#', :'data-page' => page-2) do
                  concat(page-2)
                end
              end
              make_tag(:li) do
                make_tag(:a, href: '#', :'data-page' => page-1) do
                  concat(page-1)
                end
              end
            end

            make_tag(:li, class: 'active') do
              make_tag(:a, href: '#', :'data-page' => page) do
                concat(page)
              end
            end

            if page < pages - 1
              make_tag(:li) do
                make_tag(:a, href: '#', :'data-page' => page+1) do
                  concat(page+1)
                end
              end
            end
            if page < pages - 2
              make_tag(:li) do
                make_tag(:a, href: '#', :'data-page' => page+2) do
                  concat(page+2)
                end
              end
            end

            if page < pages - 3
              make_tag(:li) do
                make_tag(:span) do
                  concat('...')
                end
              end
            end

            between = (page + pages) / 2

            if between > page + 3 && between < pages - 1

              make_tag(:li) do
                make_tag(:a, href: '#', :'data-page' => between) do
                  concat(between)
                end
              end

              make_tag(:li) do
                make_tag(:span) do
                  concat('...')
                end
              end
            end


            if page < pages
              make_tag(:li) do
                make_tag(:a, href: '#', :'data-page' => pages) do
                  concat(pages)
                end
              end
            end
          end
        end

      end # </div>
    end
  end

end
