require 'spec_helper'

describe Tabulatr::Data::Formatting do
  class DummySpecClass
    include Tabulatr::Data::Formatting
  end

  before(:each) do
    @dummy = DummySpecClass.new
    @dummy.instance_variable_set('@relation', Product.all)
  end

  describe '#apply_formats' do
    it 'applies given formatting block to a column' do
      allow(@dummy).to receive(:format_row).and_return(nil)
      p = Product.create!(title: 'title of product')
      name = :title
      output = ->(record){record.title.upcase}
      @dummy.instance_variable_set('@columns',
        {title: {output: output}}
      )
      @dummy.instance_variable_set('@assocs', {})
      result = @dummy.apply_formats
      expect(result.count).to be 1
      expect(result.first[:title]).to eql 'TITLE OF PRODUCT'
    end
  end

end
