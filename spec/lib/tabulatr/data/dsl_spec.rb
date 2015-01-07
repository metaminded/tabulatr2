require 'rails_helper'

describe Tabulatr::Data::DSL do
  class DummyDSLClass
    extend Tabulatr::Data::DSL
  end

  before(:each) do
    DummyDSLClass.instance_variable_set('@table_columns', [])
  end

  describe '#column' do
    it 'escapes table and column names' do
      allow(DummyDSLClass).to receive(:main_class).and_return(Product)
      DummyDSLClass.column(:active)
      table_column = DummyDSLClass.instance_variable_get('@table_columns').first
      expect(table_column.filter_sql).to match(/\"products\".\"active\"/)
      expect(table_column.sort_sql).to match(/\"products\".\"active\"/)
    end
  end

  describe '#association' do
    it 'escapes table and column names' do
      allow(DummyDSLClass).to receive(:main_class).and_return(Product)
      DummyDSLClass.association(:vendor, :name)
      table_column = DummyDSLClass.instance_variable_get('@table_columns').first
      expect(table_column.filter_sql).to match(/\"vendors\".\"name\"/)
      expect(table_column.sort_sql).to match(/\"vendors\".\"name\"/)
    end
  end
end