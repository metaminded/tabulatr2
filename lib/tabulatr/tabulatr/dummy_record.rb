class Tabulatr::DummyRecord

  def to_s
    "{{id}}"
  end

  def method_missing(sym)
    @methods ||= []
    @methods << sym.to_s
    "{{#{sym}}}"
  end

  def requested_methods
    @methods.uniq
  end

end
