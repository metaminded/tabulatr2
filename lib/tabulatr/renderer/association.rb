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

class Tabulatr::Renderer::Association < Tabulatr::Renderer::Column
  def human_name
    h = col_options.header
    if h && h.respond_to?(:call)
      h.()
    elsif h
      h
    else
      klass.model_name.human + ' ' + klass.human_attribute_name(name)
    end
  end

  def coltype() 'association' end
  def column?() false end
  def association?() true end

  def principal_value(record, view)
    return super if output || block
    assoc = table_name.to_s.split('-').map(&:to_sym)
    v = assoc.reduce(record) { |cur,nxt| cur.try(:send, nxt) }
    if v && v.respond_to?(:to_a) && name != :count
      v.map(&:"#{name}")
    else
      v.try(name)
    end
  end

end
