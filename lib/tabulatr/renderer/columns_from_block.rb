class Tabulatr::Renderer

  ###
  # Tabulatr::Renderer::Column
  ###
  class Column
    include ActiveModel::Model

    attr_accessor *%i{name header width align valign wrap type th_html filter_html
      filter checkbox_value checkbox_label filter_width range_filter_symbol
      sortable format_methods table_name block klass}

    def self.from(
      name: nil,
      table_name: nil,
      header: false,
      width: false,
      align: false,
      valign: false,
      wrap: true,
      type: :string,
      th_html: false,
      filter_html: false,
      filter: true,
      checkbox_value: '1',
      checkbox_label: '',
      filter_width: '97%',
      range_filter_symbol: '&ndash;',
      sortable: true,
      format_methods: [],
      klass: nil,
      &block)
      b = block_given? ? block : nil
      self.new(
        name: name,
        table_name: table_name,
        header: header,
        width: width,
        align: align,
        valign: valign,
        wrap: wrap,
        type: type,
        th_html: th_html,
        filter_html: filter_html,
        filter: filter,
        checkbox_value: checkbox_value,
        checkbox_label: checkbox_label,
        filter_width: filter_width,
        range_filter_symbol: range_filter_symbol,
        sortable: sortable,
        format_methods: format_methods,
        klass: klass,
        block: b
      )
    end

    def klassname() @_klassname ||= @klass.name.underscore end
    def human_name() header || klass.human_attribute_name(name) end
    def sort_param() "#{klassname}_sort" end
    def full_name() [table_name, name].compact.join(":") end
    def coltype() 'column' end

    def column?() true end
    def association?() false end
    def checkbox?() false end
    def action?() false end

  end

  ###
  # Tabulatr::Renderer::Association
  ###
  class Association < Column
    def human_name
      header ||
        klass.reflect_on_association(table_name.to_sym).klass.model_name.human + ' ' +
        klass.reflect_on_association(table_name.to_sym).klass.human_attribute_name(name)
    end

    def coltype() 'association' end
    def column?() false end
    def association?() true end
  end

  ###
  # Tabulatr::Renderer::Checkbox
  ###
  class Checkbox < Column
    def human_name
      nil
    end

    def coltype() 'checkbox' end
    def column?() false end
    def checkbox?() true end
  end

  ###
  # Tabulatr::Renderer::Action
  ###
  class Action < Column
    def human_name
      header
    end

    def coltype() 'action' end
    def column?() false end
    def action?() true end
  end

  ###
  # Tabulatr::Renderer::Columns
  ###
  class Columns < Array

    def initialize(klass)
      super()
      @klass = klass
    end

    def filtered_columns
      self.select &:filter
    end

    def class_name
      @klass.name.underscore
    end

  end

  ###
  # Tabulatr::Renderer::ColumnsFromBlock
  ###
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

