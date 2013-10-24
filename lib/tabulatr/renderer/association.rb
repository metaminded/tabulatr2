class Tabulatr::Renderer::Association < Tabulatr::Renderer::Column
  def human_name
    header ||
      klass.reflect_on_association(table_name.to_sym).klass.model_name.human + ' ' +
      klass.reflect_on_association(table_name.to_sym).klass.human_attribute_name(name)
  end

  def coltype() 'association' end
  def column?() false end
  def association?() true end

  def principal_value(record)
    v = record.send(table_name)
    if v && v.respond_to?(:to_a) && map
      v.map(&:"#{name}")
    else
      v.try(name)
    end
  end

end
