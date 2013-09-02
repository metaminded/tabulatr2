class Tabulatr::DummyRecord

  def to_s
    @methods ||= []
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
    Array(@method_names).try(:uniq)
  end

end
