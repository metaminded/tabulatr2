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

# We monkey patch ActiveRecord::Base to add a function for finding using
# the information of the params hash as created by a Tabulatr table
if Object.const_defined? "ActiveRecord"
  class ActiveRecord::Base
    def self.tabulatr(relation, tabulatr_data_class = nil)
      tabulatr_data_class = "#{self.name}TabulatrData".constantize unless tabulatr_data_class
      begin
        td = tabulatr_data_class.new(relation)
      rescue NameError => e
        puts e.message
        # TODO: Better message
        raise "No class `#{self.name}TabulatrData' defined. Explanation here."
      end
    end
  end
end
