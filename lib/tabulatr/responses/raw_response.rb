class Tabulatr::Responses::FileResponse < Tabulatr::Responses::DirectResponse
  attr_accessor :data, :options

  def initialze(data, options: {})
    @data = data
    @options = options
  end
end
