class Tabulatr::Renderer::Columns < ::Array

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
