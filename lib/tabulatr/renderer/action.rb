class Tabulatr::Renderer::Action < Tabulatr::Renderer::Column
  def human_name
    header
  end

  def coltype() 'action' end
  def column?() false end
  def action?() true end
end
