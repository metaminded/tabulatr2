require 'rails_helper'

describe Tabulatr::Renderer::Filter do
  describe '#to_partial_path' do
    it 'guesses the partial_path by name if no partial is given' do
      filter = Tabulatr::Renderer::Filter.new('dynamic_select')
      expect(filter.to_partial_path).to eq 'tabulatr/filter/dynamic_select'
    end

    it 'uses the given partial name if given' do
      filter = Tabulatr::Renderer::Filter.new('some_filter', partial: 'my_filters/simple_filter')
      expect(filter.to_partial_path).to eq 'my_filters/simple_filter'
    end
  end
end
