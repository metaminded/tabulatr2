module Tabulatr::Data::Formatting
  def apply_formats()
    return @relation.map do |record|
      h = HashWithIndifferentAccess.new
      rr = Data::Proxy.new(record)
      @columns.each do |name, opts|
        out = opts[:output] ? rr.instance_exec(&opts[:output]) : rr.send(name)
        h[name] = out
      end
      @assocs.each do |table_name, columns|
        h[table_name] ||= {}
        columns.each do |name, opts|
            if rr.instance_variable_get("@record").class.reflect_on_association(table_name.to_sym).collection?
              out = opts[:output] ? rr.instance_exec(&opts[:output]) : rr.try(:send, table_name).try(:map, &name).join(', ')
            else
              out = opts[:output] ? rr.instance_exec(&opts[:output]) : rr.send(table_name).try(:send, name)
            end
            h[table_name][name] = out
        end
      end
      h
    end
  end
end

Tabulatr::Data.send :include, Tabulatr::Data::Formatting
