class Tabulatr::Renderer::Checkbox < Tabulatr::Renderer::Column
  def human_name
    nil
  end

  def coltype() 'checkbox' end
  def column?() false end
  def checkbox?() true end

  def value_for(record, view)
    nil
  end
end
