module Tabulatr
  class UnexpectedSearchResultError < StandardError

    def self.raise_error(klass)
      raise self, "Your search block returned a '#{klass}'.\n
        You need to return a String, a Hash, an Array or an ActiveRecord::Relation instead."
    end
  end
end
