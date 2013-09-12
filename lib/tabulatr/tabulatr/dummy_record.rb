class Tabulatr::DummyRecord

  def self.for(klaz)
    c = Class.new(self)
    c.instance_variable_set("@model_name", klaz.model_name)
    c.new
  end

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

  def method_missing(sym, *args)
    @methods ||= []
    @methods << sym.to_s
    self
  end

  def to_key
    ["{{id}}"]
  end

  def requested_methods
    Array(@method_names).try(:uniq)
  end

  def self.model_name
    @model_name
  end

end
