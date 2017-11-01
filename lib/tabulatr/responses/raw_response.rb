class Tabulatr::Responses::FileResponse < Tabulatr::Responses::DirectResponse
  @attr_accessor :data

  def initialze(data)
    @data = data
  end
end