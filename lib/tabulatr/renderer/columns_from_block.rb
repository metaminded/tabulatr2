class Tabulatr::Renderer
  class ColumnsFromBlock
    attr_accessor :columns, :klass

    def initialize(klass)
      @klass = klass
      @columns ||= Columns.new(klass)
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
