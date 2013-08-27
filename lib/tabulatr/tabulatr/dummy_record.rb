class Tabulatr::DummyRecord

  def to_s
    if @methods.any?
      m = @methods.join(':')
      @method_names ||= []
      @method_names << m
      @methods.clear
      "{{#{m}}}"
    else
      "{{id}}"
    end
  end

  def method_missing(sym)
    @methods ||= []
    @methods << sym.to_s
    self
  end

  def requested_methods
    @method_names.uniq
  end

end
