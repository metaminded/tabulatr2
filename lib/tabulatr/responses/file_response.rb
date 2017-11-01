class Tabulatr::Responses::FileResponse < Tabulatr::Responses::DirectResponse
  @attr_accessor :file
  @attr_accessor :filename

  def initialze(file, filename: nil)
    @file = file
    @filename = filename
  end
end