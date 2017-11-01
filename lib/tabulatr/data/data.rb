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

class Tabulatr::Data

  def initialize(relation)
    @relation   = relation
    @base       = self.class.main_class rescue nil
    @base       ||= relation.respond_to?(:klass) ? relation.klass : relation
    @table_name = @base.table_name
    @search     = self.class.instance_variable_get('@search')     || HashWithIndifferentAccess.new
    @includes   = Set.new()
    @cname      = @base.name.downcase
    @batch_actions = nil
    @row = self.class.instance_variable_get('@row')
    table_columns.map do |col|
      next if col.is_a? Tabulatr::Renderer::Checkbox
      col.klass = @base.reflect_on_association(col.table_name).try(:klass) || @base
      col.determine_appropriate_filter! if col.col_options.filter === true
    end
  end

  def data_for_table(params, locals: {}, controller: nil, &block)

    @batch_actions = block if block_given?
    @controller = controller

    # count
    total = @relation.count

    # prepare the query
    apply_filters(filter_params params)
    apply_search(search_param params)
    apply_sorting(sort_params params)
    join_required_tables(params)

    batch_result = execute_batch_actions(batch_params(params), check_params(params))
    return batch_result if batch_result.is_a? Tabulatr::Responses::DirectResponse

    pagination = compute_pagination(params[:page], params[:pagesize])
    apply_pagination(pagination.slice(:offset, :pagesize))

    # get the records
    found = apply_formats(locals: locals, controller: controller)

    append = params[:append].present? ? Tabulatr::Utility.string_to_boolean(params[:append]) : false

    # prepare result for rendering
    found.define_singleton_method(:__pagination) do
      { :page => pagination[:page],
        :pagesize => pagination[:pagesize],
        :count => pagination[:count],
        :pages => pagination[:pages],
        :total => total,
        :append => append,
        :table_id => params[:table_id]
      }
    end


    found.define_singleton_method(:to_tabulatr_json) do |klass=nil|
      Tabulatr::JsonBuilder.build found, klass, params[:arguments]
    end

    found
  end

  def execute_batch_actions batch_param, selected_ids
    if batch_param.present? && @batch_actions.present?
      batch_param = batch_param.keys.first.to_sym if batch_param.is_a?(Hash)
      selected_ids = @relation.map(&:id) if selected_ids.empty?
      return @batch_actions.yield(Invoker.new(batch_param, selected_ids))
    end
  end

  def table_columns
    self.class.instance_variable_get("@table_columns")
  end

  def filters
    self.class.instance_variable_get('@filters')
  end

  def search?
    self.class.instance_variable_get('@search')
  end

  #--
  # Params
  #++

  def filter_params(params) params["#{Tabulatr::Utility.formatted_name(@base.name)}_filter"] end
  def search_param(params)  params["#{Tabulatr::Utility.formatted_name(@base.name)}_search"] end
  def sort_params(params)   params["#{Tabulatr::Utility.formatted_name(@base.name)}_sort"] end
  def batch_params(params)  params["#{Tabulatr::Utility.formatted_name(@base.name)}_batch"] end
  def check_params(params)
    tabulatr_checked = params["tabulatr_checked"]
    if tabulatr_checked.present?
      tabulatr_checked['checked_ids'].split(',')
    end
  end

  def join_required_tables(params)
    if params[:arguments].present?
      tt = (params[:arguments].split(",").select{|s| s[':']}.map do |s|
            s.split(':').first
          end.uniq.map(&:to_sym))
      tt.delete(@table_name.to_sym)
      @includes = @includes + tt
    end
    # @relation = @relation.includes(@includes.map(&:to_sym)).references(@includes.map(&:to_sym))
    @relation = @relation.eager_load(@includes.map(&:to_sym))
    # @relation = @relation.group("#{@table_name}.#{@base.primary_key}")
  end

  def table_name_for_association(assoc)
    @base.reflect_on_association(assoc.to_sym).table_name
    # assoc.to_sym
  end

end

require_relative './dsl'
require_relative './filtering'
require_relative './invoker'
require_relative './sorting'
require_relative './pagination'
require_relative './formatting'
require_relative './row'
require_relative './proxy'
require_relative './button_builder'
