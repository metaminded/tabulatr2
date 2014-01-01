module Tabulatr
  class RequestDataNotIncludedError < StandardError

    def self.raise_error(method, object)
      raise self, "You requested '#{method}' on '#{object}' but
          there was no such method included in your TabulatrData"
    end
  end
end