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

  # render the select tag or the buttons for batch actions
  def render_batch_actions
    iname = "#{@classname}#{TABLE_FORM_OPTIONS[:batch_postfix]}"
    make_tag(:span, :class => 'dropdown') do
      make_tag(:i, :id => 'tabulatr-wrench', :class => 'icon-wrench hide',  :'data-toggle' => "dropdown"){}
      make_tag(:ul, class: 'dropdown-menu', role: 'menu', :'aria-labelledby' => 'dLabel') do
        @table_options[:batch_actions].each do |n,v|
          make_tag(:li) do
            make_tag(:a, :value => v,
              :name => "#{iname}[#{n}]",
              :class => "btn") do
              concat(v)
            end
          end
        end
      end
    end
  end

end
