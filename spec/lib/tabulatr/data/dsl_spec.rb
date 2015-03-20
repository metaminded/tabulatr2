require 'rails_helper'

describe Tabulatr::Data::DSL do
  class DummyDSLClass
    extend Tabulatr::Data::DSL
  end

  before(:each) do
    DummyDSLClass.instance_variable_set('@table_columns', [])
    DummyDSLClass.instance_variable_set('@filters', [])
    allow(DummyDSLClass).to receive(:main_class).and_return(Product)
    DummyDSLClass.instance_variable_set('@target_class', nil)
    DummyDSLClass.instance_variable_set('@target_class_name', nil)
  end

  describe '#column' do
    it 'escapes table and column names' do
      DummyDSLClass.column(:active)
      table_column = DummyDSLClass.instance_variable_get('@table_columns').first
      expect(table_column.col_options.filter_sql).to match(/\"products\".\"active\"/)
      expect(table_column.col_options.sort_sql).to match(/\"products\".\"active\"/)
    end

    it 'uses the sql option as both sort_sql and filter_sql' do
      allow(DummyDSLClass).to receive(:main_class).and_return(Product)
      DummyDSLClass.column(:active, sql: 'products.activated')
      table_column = DummyDSLClass.instance_variable_get('@table_columns').first
      expect(table_column.col_options.filter_sql).to match(/products\.activated/)
      expect(table_column.col_options.sort_sql).to match(/products\.activated/)
    end

    it 'uses the block as output if given' do
      allow(DummyDSLClass).to receive(:main_class).and_return(Product)
      output = ->(record){record.title}
      DummyDSLClass.column(:active, &output)
      table_column = DummyDSLClass.instance_variable_get('@table_columns').first
      expect(table_column.output).to eq output
    end

    it 'uses a standard output if no block is given' do
      allow(DummyDSLClass).to receive(:main_class).and_return(Product)
      DummyDSLClass.column(:title)
      table_column = DummyDSLClass.instance_variable_get('@table_columns').first
      test_obj = double(title: 'Hello world!')
      expect(table_column.output.call(test_obj)).to eq(test_obj.title)
    end
  end

  describe '#association' do
    it 'escapes table and column names' do
      DummyDSLClass.association(:vendor, :name)
      table_column = DummyDSLClass.instance_variable_get('@table_columns').first
      expect(table_column.col_options.filter_sql).to match(/\"vendors\".\"name\"/)
      expect(table_column.col_options.sort_sql).to match(/\"vendors\".\"name\"/)
    end

    it 'uses the block as output if given' do
      allow(DummyDSLClass).to receive(:main_class).and_return(Product)
      output = ->(record){ 'test this thing' }
      DummyDSLClass.association(:vendor, :name, &output)
      table_column = DummyDSLClass.instance_variable_get('@table_columns').first
      expect(table_column.output).to eq output
    end

    it 'uses a standard output if no block is given' do
      allow(DummyDSLClass).to receive(:main_class).and_return(Product)
      DummyDSLClass.association(:vendor, :name)
      table_column = DummyDSLClass.instance_variable_get('@table_columns').first
      test_obj = double(vendor: double(name: 'Hello world!'))
      expect(table_column.output.call(test_obj)).to eq(test_obj.vendor.name)
    end
  end

  describe '#main_class' do
    it 'returns the target_class' do
      DummyDSLClass.instance_variable_set('@target_class', Product)
      allow(DummyDSLClass).to receive(:target_class_name).and_return('')
      expect(DummyDSLClass.main_class).to eq(Product)
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
