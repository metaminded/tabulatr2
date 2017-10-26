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

class ActionController::Base
  before_action do
    @_tabulatr_table_index = 0
  end

  def tabulatr_for(relation, tabulatr_data_class: nil, serializer: nil, render_action: nil, default_order: nil, locals: {}, &block)
    klass = relation.respond_to?(:klass) ? relation.klass : relation
    respond_to do |format|
      format.json {
        locals[:current_user] ||= current_user if respond_to?(:current_user)
        records = klass.tabulatr(relation, tabulatr_data_class).data_for_table(params, locals: locals, controller: self, default_order: default_order, &block)
        render json: records.to_tabulatr_json(serializer)
        records
      }
      format.html {
        render action: render_action || action_name
        nil
      }
    end
  end
end
