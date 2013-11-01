require 'spec_helper'

describe Tabulatr::Data do
  it 'prefilters the result' do
    Tabulatr::Data.any_instance.stub_chain(:table_columns, :klass=).and_return(Product)
    Tabulatr::Data.any_instance.stub_chain(:table_columns, :map).as_null_object

    td = Tabulatr::Data.new(Product.where(price: 10))
    td.data_for_table(example_params)
    expect(td.instance_variable_get('@relation').to_sql).to match(/.+WHERE \"products\".\"price\" = 10.+/)
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
