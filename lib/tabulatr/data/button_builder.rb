#--
# Copyright (c) 2010-2014 Peter Horn & Florian Thomas, tickettoaster GmbH
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

# buttons do |b,r|
#   b.button :'eye-open', foo_path(r), class: 'btn-success'
#   b.button :'pencil', edit_foo_path(r), class: 'btn-warning'
#   b.submenu do |s|
#     s.button :star, star_foor_path(r), label: 'Dolle Sache'
#     s.divider
#     s.button :'trash-o', foo_path(r), label: 'Löschen', confirm: 'echt?', class: 'btn-danger', method: :delete
#   end
# end


class Tabulatr::Data::ButtonBuilder

  def initialize
    @mode = :buttons
    @buttons = []
    @submenu = []
    val
  end

  def val
    {buttons: @buttons, submenu: @submenu}
  end

  def button(icon, path, options={})
    label = options.dup.delete(:label)
    if @mode == :buttons
      @buttons << {icon: icon, path: path, options: options}
    else
      @submenu << {icon: icon, label: label, path: path, options: options}
    end
    val
  end

  def submenu(&block)
    raise "No submenus in submenus, sorry" if @mode == :submenu
    @mode = :submenu
    yield(self)
    @mode = :buttons
    val
  end

  def divider
    raise "use dividers only in submenu" unless @mode == :submenu
    @submenu << :divider
    val
  end
end
