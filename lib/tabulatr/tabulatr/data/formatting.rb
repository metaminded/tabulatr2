module Tabulatr::Data::Formatting
  def apply_formats()
    @relation.map do |record|
      rr = Data::Proxy.new(record)
      h = {}
      @columns.each do |name, opts|
        out = opts[:output] ? rr.instance_exec(&opts[:output]) : rr.send(name)
        h[name] = out
      end
      @assocs.each do |table_name, columns|
        Hash[@columns.each do |name, opts|
            out = opts[:output] ? rr.instance_exec(&opts[:output]) : rr.send(name)
            [name, out]
          end

        out = opts[:output] ? rr.instance_exec(&opts[:output]) : rr.send(name)
        h[name] = out
      end


    end
  end
end

Tabulatr::Data.send :include, Tabulatr::Data::Formatting
