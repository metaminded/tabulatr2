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

# These are extensions for use from ActionController instances
# In a seperate class call only for clearity

require 'activerecord_outer_joins'

module Tabulatr::Finder

  # -------------------------------------------------------------------
  # Called if SomeActveRecordSubclass::find_for_table(params) is called
  #
  def self.find_for_table(klaz, params, options={}, &block)
    adapter = if klaz.respond_to?(:descends_from_active_record?) then ::Tabulatr::Adapter::ActiveRecordAdapter.new(klaz)
      else raise("Don't know how to deal with class '#{klaz}'")
    end

    Tabulatr::Security.validate!("#{params[:arguments]}-#{params[:salt]}-#{params[:hash]}")

    form_options    = Tabulatr.table_form_options
    opts            = Tabulatr.finder_options.merge(options)
    params          ||= {} # just to be sure
    cname           = adapter.class_to_param
    sort_name       = "#{cname}#{form_options[:sort_postfix]}"
    filter_name     = "#{cname}#{form_options[:filter_postfix]}"
    batch_name      = "#{cname}#{form_options[:batch_postfix]}"
    check_name      = "tabulatr_checked"
    append = params[:append].present? ? params[:append] : false


    append = string_to_boolean append
    # before we do anything else, we find whether there's something to do for batch actions
    checked_param = ActiveSupport::HashWithIndifferentAccess.new({:checked_ids => '', :current_page => []}).
      merge(params[check_name] || {})

    id = adapter.primary_key

    serializer = options[:serializer].presence

    # checkboxes
    checked_ids = checked_param[:checked_ids]
    selected_ids = checked_ids.split(',')

    execute_batch_actions(params[batch_name], selected_ids, &block)

    # at this point, we've retrieved the filter settings, the sorting setting, the pagination settings and
    # the selected_ids.
    filter_param = (params[filter_name] || {})
    sortparam = params[sort_name]

    includes = []
    maps = klaz.tabulatr_name_mappings.merge(opts[:name_mapping] || {})

    build_conditions(filter_param, form_options, includes, adapter, maps)
    order = build_order(params[:sort_by], params[:orientation], params[:default_order], maps, adapter, klaz)

    c = adapter.includes(includes).references(includes).count
    # Group statments return a hash
    c = c.count unless c.class == Fixnum
    pagesize = params[:pagesize]
  pagination_data = build_offset(params[:page], pagesize, c, opts)

    total = adapter.preconditions_scope(opts).count
    # here too
    total = total.count unless total.class == Fixnum

    # Now, actually find the stuff
    opts[:name_mapping] ||= {}
    find_on = (klaz.tabulatr_select_attributes(opts[:name_mapping]).try do |s| adapter.select(s) end) || adapter
    found = find_on.outer_joins(includes)
            .limit(pagination_data[:pagesize]).offset(pagination_data[:offset])
            .order(order).to_a

    found.define_singleton_method(:__pagination) do
      { :page => pagination_data[:page],
        :pagesize => pagination_data[:pagesize],
        :count => c,
        :pages => pagination_data[:pages],
        :pagesizes => {},
        :total => total,
        :append => append,
        :table_id => params[:table_id] }
    end

    found.define_singleton_method(:to_tabulatr_json) do |klass=nil|
      Tabulatr::JsonBuilder.build found, klass, params[:arguments], id
    end

    found
  end

  private

  def self.execute_batch_actions batch_param, selected_ids, &block
    if batch_param.present? && block_given?
      batch_param = batch_param.keys.first.to_sym if batch_param.is_a?(Hash)
      yield(Invoker.new(batch_param, selected_ids))
    end
  end

  def self.string_to_boolean str
    if str == 'true'
      str = true
    elsif str == 'false'
      str = false
    end
    str
  end

end
