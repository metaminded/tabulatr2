class Tabulatr::Responses::FileResponse < Tabulatr::Responses::DirectResponse
  attr_accessor :file, :options

  def initialze(file, options: {})
    @file = file
    @options = options
  end
end
