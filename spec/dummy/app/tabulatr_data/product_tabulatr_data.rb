class ProductTabulatrData < Tabulatr::Data

  search :title

  # search do |query| "adsd like query" end

  column :id
  column :title
  column :price do "#{price} EUR" end # <- Block evaluiert im Kontext EINES Records
  column :edit_link do link_to "edit #{title}", product_path(id) end
  # column :name,
  #   sort: "firstname || ' ' || lastname"
  #   filter: "firstname || ' ' || lastname"
  #   do
  #     "#{firstname} #{lastname}"
  # end
  association :vendor, :name
  association :tag, :title do "'#{title.upcase}'" end

end
