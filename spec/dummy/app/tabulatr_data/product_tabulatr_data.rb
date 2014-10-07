class ProductTabulatrData < Tabulatr::Data

  search :vendor_product_name, :price, :title

  # search do |query|
  #   "products.title LIKE '#{query}'"
  # end

  column :title
  column :id
  column :price, table_column_options: {filter: :range} do "#{record.price} EUR" end # <- Block evaluiert im Kontext EINES Records
  column :edit_link do link_to "edit #{record.title}", product_path(record) end
  # column :name,
  #   sort: "firstname || ' ' || lastname"
  #   filter: "firstname || ' ' || lastname"
  #   do
  #     "#{firstname} #{lastname}"
  # end
  column :vendor_product_name,
    sort_sql: "products.title || '' || vendors.name",
    filter_sql: "products.title || '' || vendors.name",
    header: 'Product by vendor' do
    "#{record.title} from #{record.vendor.try(:name)}"
  end
  column :active, sortable: false
  column :updated_at, table_column_options: { filter: :date } do "#{record.updated_at.strftime('%H:%M %d.%m.%Y')}" end
  association :vendor, :name, table_column_options: { filter: :exact }
  association :tags, :title do |r|
    "'#{r.tags.map(&:title).map(&:upcase).join(', ')}'"
  end
  association :tags, :count

  buttons width: '200px' do |b,r|
    b.button :eye, product_path(r), class: 'btn-success'
    b.button :pencil, edit_product_path(r), class: 'btn-warning'
    b.submenu do |s|
      s.button :star, product_path(r), label: 'Dolle Sache'
      s.divider
      s.button :'trash-o', product_path(r), label: 'Löschen', confirm: 'echt?', class: 'btn-danger', method: :delete
    end
    "haha!"
  end
end
