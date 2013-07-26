class Tabulatr::DummyRecord

  # def to_s
  #   "{{id}}"
  # end

  def method_missing(sym)
    "{{#{sym}}}"
  end

end
