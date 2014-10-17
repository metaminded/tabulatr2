require 'spec_helper'

describe Tabulatr::Data::DSL do
  class DummySpecClass
    extend Tabulatr::Data::DSL
  end

  before(:each) do
    DummySpecClass.instance_variable_set('@table_columns', [])
  end

  describe '#column' do
    it 'escapes table and column names' do
      allow(DummySpecClass).to receive(:main_class).and_return(Product)
      DummySpecClass.column(:active)
      table_column = DummySpecClass.instance_variable_get('@table_columns').first
      expect(table_column.filter_sql).to match(/\"products\".\"active\"/)
      expect(table_column.sort_sql).to match(/\"products\".\"active\"/)
    end
  end

  describe '#association' do
    it 'escapes table and column names' do
      allow(DummySpecClass).to receive(:main_class).and_return(Product)
      DummySpecClass.association(:vendor, :name)
      table_column = DummySpecClass.instance_variable_get('@table_columns').first
      expect(table_column.filter_sql).to match(/\"vendors\".\"name\"/)
      expect(table_column.sort_sql).to match(/\"vendors\".\"name\"/)
    end
  end
end