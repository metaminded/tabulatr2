class ProductTabulatrData < Tabulatr::Data

  search :vendor_product_name, :price, :title

  # search do |query|
  #   "products.title LIKE '#{query}'"
  # end

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
  column :vendor_product_name, sort_sql: "products.title || '' || vendors.name", filter_sql: "products.title || '' || vendors.name" do
    "#{title} from #{vendor.try(:name)}"
  end
  column :active
  column :updated_at do "#{updated_at.strftime('%H:%M %d.%m.%Y')}" end
  association :vendor, :name
  association :tags, :title do "'#{tags.map(&:title).map(&:upcase).join(', ')}'" end

end
