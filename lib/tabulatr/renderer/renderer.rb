class Tabulatr::Renderer

  def initialize(klass, view=nil, toptions={})
    @klass = klass
    @view = view
    @table_options = Tabulatr::Settings::TABLE_OPTIONS.merge(toptions)
    @classname = @klass.name.underscore
  end

  def build_table(&block)
    @columns = ColumnsFromBlock.process @klass, &block

    @view.render(partial: '/tabulatr/tabulatr_table', locals: {
      columns: @columns,
      table_options: @table_options,
      klass: @klass,
      classname: @classname
    })
  end

end
