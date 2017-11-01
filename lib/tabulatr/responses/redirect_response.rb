class Tabulatr::Responses::RedirectResponse < Tabulatr::Responses::DirectResponse
  attr_accessor :url, :ids

  def initialze(url, ids: nil)
    @url = url
    @ids = ids
  end
end
