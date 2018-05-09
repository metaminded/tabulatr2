require 'rails_helper'

describe Tabulatr::Data do

  before do
    col_options = Tabulatr::ParamsBuilder.new(sort_sql: 'products.title', filter_sql: 'products.title')
    column = Tabulatr::Renderer::Column.from(
        name: :title,
        klass: Product,
        table_name: :products,
        col_options: col_options,
        output: ->(record){record.send(:title)}
    )
    allow_any_instance_of(Tabulatr::Data).to receive(:table_columns).and_return([column])
  end

  it 'prefilters the result' do

    td = Tabulatr::Data.new(Product.where(price: 10))
    td.data_for_table(ActionController::Parameters.new(example_params))
    expect(td.instance_variable_get('@relation').to_sql).to match(/.+WHERE \"products\".\"price\" = 10.+/)
  end

  it 'uses default order' do
    Product.create([{title: 'foo', price: 5}, {title: 'bar', price: 10}, {title: 'fuzz', price: 7}])

    td = Tabulatr::Data.new(Product)
    records = td.data_for_table(ActionController::Parameters.new(example_params.merge(product_sort: 'title DESC')))
    expect(records.count).to eql 3
    titles = ['fuzz', 'foo', 'bar']
    # raise records.inspect
    records.each_with_index do |r, ix|
      expect(r[:products][:title]).to eql titles[ix]
    end
  end

  it 'invokes the batch actions invoker with all ids if no row is selected' do
    Product.create([{title: 'foo', price: 5, active: true}, {title: 'bar', price: 10, active: false}, {title: 'fuzz', price: 7, active: true}])

    td = Tabulatr::Data.new(Product.where(active: true))
    td.instance_variable_set(:@batch_actions, ->(batch_actions){
      batch_actions.delete do |ids|
        Product.where(id: ids).destroy_all
      end
    })
    td.data_for_table(ActionController::Parameters.new(example_params.merge(product_batch: 'delete', 'tabulatr_checked' => {'checked_ids' => ''})))
    expect(Product.where(active: true).count).to be 0
    expect(Product.count).to be 1
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
