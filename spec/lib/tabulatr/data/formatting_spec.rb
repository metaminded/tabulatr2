require 'rails_helper'

describe Tabulatr::Data::Formatting do
  class DummyFormattingClass
    include Tabulatr::Data::Formatting
    def table_columns; end
  end

  before(:each) do
    @dummy = DummyFormattingClass.new
    @dummy.instance_variable_set('@relation', Product.all)
    column = Tabulatr::Renderer::Column.from(
        name: :title,
        klass: Product,
        table_name: :products,
        sort_sql: "products.title",
        filter_sql: "products.title"
    )
    allow(@dummy).to receive(:table_columns).and_return([column])
  end

  describe '#apply_formats' do
    it 'applies given formatting block to a column' do
      allow(@dummy).to receive(:format_row).and_return(nil)
      p = Product.create!(title: 'title of product')
      @dummy.table_columns.first.output = ->(record){record.title.upcase}
      result = @dummy.apply_formats
      expect(result.count).to be 1
      expect(result.first[:products][:title]).to eql 'TITLE OF PRODUCT'
    end
  end

end
