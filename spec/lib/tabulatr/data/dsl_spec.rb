require 'rails_helper'

describe Tabulatr::Data::DSL do
  class DummyDSLClass
    extend Tabulatr::Data::DSL
  end

  before(:each) do
    DummyDSLClass.instance_variable_set('@table_columns', [])
    DummyDSLClass.instance_variable_set('@filters', [])
    allow(DummyDSLClass).to receive(:main_class).and_return(Product)
  end

  describe '#column' do
    it 'escapes table and column names' do
      DummyDSLClass.column(:active)
      table_column = DummyDSLClass.instance_variable_get('@table_columns').first
      expect(table_column.filter_sql).to match(/\"products\".\"active\"/)
      expect(table_column.sort_sql).to match(/\"products\".\"active\"/)
    end
  end

  describe '#association' do
    it 'escapes table and column names' do
      DummyDSLClass.association(:vendor, :name)
      table_column = DummyDSLClass.instance_variable_get('@table_columns').first
      expect(table_column.filter_sql).to match(/\"vendors\".\"name\"/)
      expect(table_column.sort_sql).to match(/\"vendors\".\"name\"/)
    end
  end

  describe '#filter' do
    it 'adds filters' do
      DummyDSLClass.filter(:price_range)
      expect(DummyDSLClass.instance_variable_get('@filters').map(&:name)).to match_array([:price_range])
    end

    it 'can hold multiple filters' do
      DummyDSLClass.filter(:price_range)
      DummyDSLClass.filter(:category_select)
      expect(DummyDSLClass.instance_variable_get('@filters').map(&:name)).to match_array([:price_range, :category_select])
    end

    it 'accepts a partial attribute' do
      DummyDSLClass.filter(:simple_filter, partial: 'my_custom_filter')
      expect(DummyDSLClass.instance_variable_get('@filters').first.partial).to eq 'my_custom_filter'
    end
  end
end
