class Tabulatr::Responses::RawResponse < Tabulatr::Responses::DirectResponse
  attr_accessor :data, :options

  def initialize(data, options={})
    @data = data
    @options = options
  end
end
