require 'rails_helper'

describe Tabulatr::Renderer::ColumnsFromBlock do

  class TabulatrFakeData < Tabulatr::Data
    filter :foo_and_bar
    filter :not_requested_filter
  end

  describe '#filter' do
    it 'finds filters if tabulatr_data is given' do
      allow_any_instance_of(TabulatrFakeData).to receive(:table_columns).and_return([])
      td = TabulatrFakeData.new(Product)
      cfb = Tabulatr::Renderer::ColumnsFromBlock.process(Product, td) do |c|
        c.filter :foo_and_bar
        c.filter :not_available_filter
      end
      expect(cfb.filters.map(&:name)).to match_array([:foo_and_bar])
    end
  end
end
