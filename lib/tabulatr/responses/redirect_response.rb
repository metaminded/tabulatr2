class Tabulatr::Responses::RedirectResponse < Tabulatr::Responses::DirectResponse
  attr_accessor :url, :ids

  def initialize(url, ids: nil)
    @url = url
    @ids = ids
  end
end
