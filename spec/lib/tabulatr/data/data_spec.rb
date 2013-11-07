require 'spec_helper'

describe Tabulatr::Data do

  before do
    Tabulatr::Data.any_instance.stub_chain(:table_columns, :klass=).and_return(Product)
    Tabulatr::Data.any_instance.stub_chain(:table_columns, :map).as_null_object
  end

  it 'prefilters the result' do

    td = Tabulatr::Data.new(Product.where(price: 10))
    td.data_for_table(example_params)
    expect(td.instance_variable_get('@relation').to_sql).to match(/.+WHERE \"products\".\"price\" = 10.+/)
  end

  it 'uses default order' do
    Product.create([{title: 'foo', price: 5}, {title: 'bar', price: 10}, {title: 'fuzz', price: 7}])

    cols = {
      title: {
        name: 'title',
        sort_sql: nil,
        filter_sql: nil,
        output: nil,
        table_column: Tabulatr::Renderer::Column.from(name: 'title', klass: Product)
      }
    }
    Tabulatr::Data.instance_variable_set('@columns', cols)
    td = Tabulatr::Data.new(Product)
    # mod_params = example_params.merge(product_sort: 'products.title DESC')
    # raise mod_params.inspect
    records = td.data_for_table(HashWithIndifferentAccess.new(example_params.merge(product_sort: 'products.title DESC')))
    expect(records.count).to eql 3
    titles = ['fuzz', 'foo', 'bar']
    records.each_with_index do |r, ix|
      expect(r[:title]).to eql titles[ix]
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
