module Tabulatr::Data::Pagination

  def apply_pagination(offset: 0, pagesize: nil, pages: nil, page: 1, count: nil)
    @relation = @relation.limit(pagesize).offset(offset)
  end

  def compute_pagination(page, pagesize)
    count = @relation.count
    page ||= 1
    pagesize, page = pagesize.to_i, page.to_i

    pages = (count/pagesize.to_f).ceil
    page = [page, pages].min

    {
      offset: [0,((page-1)*pagesize).to_i].max,
      pagesize: pagesize,
      pages: pages,
      page: page,
      count: count
    }
  end
end

Tabulatr::Data.send :include, Tabulatr::Data::Pagination
