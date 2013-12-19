class Tabulatr::Data::Formatting::Row

  attr_accessor :attributes

  def initialize
    self.attributes = {class: 'tabulatr-row'}
  end
end
