class Tabulatr::Renderer::Filter

  attr_accessor :name, :partial, :block

  def initialize(name, partial: nil, &block)
    @name = name
    @block = block
    @partial = partial
  end

  def filter
    :custom
  end

  def to_partial_path
    if partial.present?
      partial
    else
      "tabulatr/filter/#{name.to_s.downcase.underscore}"
    end
  end
end
