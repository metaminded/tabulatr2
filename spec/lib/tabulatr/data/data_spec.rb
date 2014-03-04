require 'spec_helper'

describe Tabulatr::Data do

  before do
    column = Tabulatr::Renderer::Column.from(
        name: :title,
        klass: Product,
        table_name: :products,
        sort_sql: "products.title",
        filter_sql: "products.title",
        output: ->(record){record.send(:title)}
    )
    Tabulatr::Data.any_instance.stub(:table_columns).and_return([column])
  end

  it 'prefilters the result' do

    td = Tabulatr::Data.new(Product.where(price: 10))
    td.data_for_table(example_params)
    expect(td.instance_variable_get('@relation').to_sql).to match(/.+WHERE \"products\".\"price\" = 10.+/)
  end

  it 'uses default order' do
    Product.create([{title: 'foo', price: 5}, {title: 'bar', price: 10}, {title: 'fuzz', price: 7}])

    td = Tabulatr::Data.new(Product)
    records = td.data_for_table(HashWithIndifferentAccess.new(example_params.merge(product_sort: 'title DESC')))
    expect(records.count).to eql 3
    titles = ['fuzz', 'foo', 'bar']
    # raise records.inspect
    records.each_with_index do |r, ix|
      expect(r[:products][:title]).to eql titles[ix]
    end
  end
end


private

def example_params
  {
    page: 1,
    pagesize: 20,
    arguments: 'title,price,active,vendor_product_name,updated_at,vendor:name,tags:title',
    table_id: 'product_table',
    product_search: nil,
    product_sort: nil
  }
end
