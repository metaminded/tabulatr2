class Tabulatr::Data

  def initialize(relation)
    @relation   = relation
    @base       = relation.respond_to?(:klass) ? relation.klass : relation
    @table_name = @base.table_name
    @assocs     = self.class.instance_variable_get('@assocs')
    @columns    = self.class.instance_variable_get('@columns')
    @includes   = Set.new()
    @cname      = @base.name
  end

  def data_for_table(params)
    check_request_signature!(params)
    # prepare the query
    apply_filters(filter_params params)
    apply_search(search_param params)
    apply_sorting(sort_params params)
    join_required_tables(params)

    pagination = compute_pagination(params[:page], params[:pagesize])
    apply_pagination(pagination)

    # TODO: batch actions and checked ids

    # get the records
    found = apply_formats()

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

    puts found.inspect

    found.define_singleton_method(:to_tabulatr_json) do |klass=nil|
      Tabulatr::JsonBuilder.build found, klass, params[:arguments]
    end

    found
  end

  def check_request_signature!(params)
    Tabulatr::Security.validate!("#{params[:arguments]}-#{params[:salt]}-#{params[:hash]}")
  end

  def execute_batch_actions batch_param, selected_ids, &block
    raise "FIXME"
    if batch_param.present? && block_given?
      batch_param = batch_param.keys.first.to_sym if batch_param.is_a?(Hash)
      yield(Invoker.new(batch_param, selected_ids))
    end
  end

  #--
  # Params
  #++

  def filter_params(params) params["#{@cname}_filter"] end
  def search_param(params)  params["#{@cname}_search"] end
  def sort_params(params)   params["#{@cname}_sort"] end
  def batch_params(params)  params["#{@cname}_batch"] end
  def check_params(params)  params["tabulatr_checked"] end

  #--
  # Access the sctual data
  #++
  def build_column_name(colname, table_name: nil, use_for: nil)
    puts ">>>>>>>>>> #{colname}"
    if colname['.']
      t,c = colname.split(".")
      return build_column_name(c, table_name: t, use_for: use_for)
    end
    table_name ||= @table_name
    if table_name == @table_name
      mapping = case use_for.to_sym
      when :filter then @columns[colname][:filter_sql]
      when :sort then @columns[colname][:sort_sql]
      end
      return mapping if mapping.present?
    else
      @includes << table_name.to_sym
      mapping = case use_for.to_sym
      when :filter then @assoc[table_name.to_sym][colname][:filter_sql]
      when :sort then @assoc[table_name.to_sym][colname][:sort_sql]
      end
      return mapping if mapping.present?
    end

    t = "#{table_name}.#{colname}"
    raise "SECURITY violation, field name is '#{t}'" unless /^[\d\w]+(\.[\d\w]+)?$/.match t
    t
  end

  def join_required_tables(params)
    tt = (params[:arguments].split(",").select{|s| s[':']}.map do |s|
          table_name_for_association(s.split(':').first)
        end.uniq)
    @includes = @includes + tt
    puts "-----#{@includes.inspect}"
    puts @includes.map(&:to_s)
    @relation = @relation.outer_joins(@includes.map(&:to_sym))
  end

  def table_name_for_association(assoc)
    # ass = @base.reflect_on_association(assoc.to_sym)
    # .table_name
    assoc.to_sym
  end

end

require_relative './dsl'
require_relative './filtering'
require_relative './sorting'
require_relative './pagination'
require_relative './formatting'
require_relative './proxy'
