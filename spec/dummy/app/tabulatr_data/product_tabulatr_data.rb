class ProductTabulatrData < Tabulatr::Data

  search :vendor_product_name, :price, :title

  # search do |query|
  #   "products.title LIKE '#{query}'"
  # end

  column :title
  column :id
  column :price do "#{record.price} EUR" end # <- Block evaluiert im Kontext EINES Records
  column :edit_link do link_to "edit #{record.title}", product_path(record) end
  # column :name,
  #   sort: "firstname || ' ' || lastname"
  #   filter: "firstname || ' ' || lastname"
  #   do
  #     "#{firstname} #{lastname}"
  # end
  column :vendor_product_name, sort_sql: "products.title || '' || vendors.name", filter_sql: "products.title || '' || vendors.name" do
    "#{record.title} from #{record.vendor.try(:name)}"
  end
  column :active
  column :updated_at, table_column_options: { filter: :date } do "#{record.updated_at.strftime('%H:%M %d.%m.%Y')}" end
  association :vendor, :name
  association :tags, :title do |r|
    "'#{r.tags.map(&:title).map(&:upcase).join(', ')}'"
  end

end
