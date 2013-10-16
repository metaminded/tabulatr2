module Tabulatr::Data::DSL

  def column(name, sort_sql: nil, filter_sql: nil, sql: nil, &block)
    @columns ||= {}
    @columns[name.to_sym] = {
      name: name,
      sort_sql: sort_sql || sql,
      filter_sql: filter_sql || sql,
      output: block
    }
  end

  def association(assoc, name, sort_sql: nil, filter_sql: nil, sql: nil, &block)
    @assocs ||= {}
    @assocs[assoc.to_sym] ||= {}
    @assocs[assoc.to_sym][name.to_sym] = {
      name: name,
      sort_sql: sort_sql || sql,
      filter_sql: filter_sql || sql,
      output: block
    }
  end

  def search(*args, &block)
    raise "either column or block" if args.present? && block_given?
    @search = args.presence || block
  end
end

Tabulatr::Data.send :extend, Tabulatr::Data::DSL
