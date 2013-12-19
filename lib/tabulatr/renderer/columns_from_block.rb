#--
# Copyright (c) 2010-2014 Peter Horn & Florian Thomas, Provideal GmbH
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

class Tabulatr::Renderer
  class ColumnsFromBlock
    attr_accessor :columns, :klass

    def initialize(klass)
      @klass = klass
      @columns ||= []
    end

    def column(name, opts={}, &block)
      @columns << Column.from(opts.merge(klass: klass, name: name), &block)
    end

    def association(table_name, name, opts={}, &block)
      @columns << Association.from(opts.merge(klass: klass, name: name, table_name: table_name), &block)
    end

    def checkbox(opts={})
      @columns << Checkbox.from(opts.merge(klass: klass, filter: false, sortable: false))
    end

    def action(opts={}, &block)
      @columns << Action.from(opts.merge(klass: klass, filter: false, sortable: false), &block)
    end

    def self.process(klass, &block)
      i = self.new(klass)
      yield(i)
      c = i.columns
      c
    end
  end
end
