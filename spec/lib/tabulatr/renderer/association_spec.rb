require 'rails_helper'

describe Tabulatr::Renderer::Association do

  describe '#principal_value' do

    before {
      @p = Product.create(title: 'product')
      @p.tags.create(title: 'foo')
      @p.tags.create(title: 'bar')
    }

    context 'name == "count"' do
      it 'returns the associations\'s count' do
        assoc = Tabulatr::Renderer::Association.from(table_name: 'tags', name: :count)
        expect(assoc.principal_value(@p, nil)).to eq 2

      end
    end

    context 'name != "count"' do
      it 'maps the association' do
        assoc = Tabulatr::Renderer::Association.from(table_name: 'tags', name: :title)
        expect(assoc.principal_value(@p, nil)).to match_array(['foo', 'bar'])
      end
    end

  end
end
