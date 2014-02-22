require 'spec_helper'

describe Tabulatr::Data::ColumnNameBuilder do
  class DummySpecClass
    include Tabulatr::Data::ColumnNameBuilder
  end
  
  describe '#build_column_name' do

    before(:each) do
      @dummy = DummySpecClass.new
      @dummy.instance_variable_set('@includes', [])
      @dummy.instance_variable_set('@columns', {})
      @dummy.instance_variable_set('@table_name', 'products')
      @dummy.instance_variable_set('@relation', Product.all)
    end

    it 'builds a table.column name from a column' do
      expect(@dummy.build_column_name('title')).to eql 'products.title'
    end

    it 'builds a table.column name from an association' do
      @dummy = DummySpecClass.new
      @dummy.instance_variable_set('@assocs', {vendor: {name: nil}})
      @dummy.instance_variable_set('@includes', [])
      expect(@dummy.build_column_name('name', table_name: 'vendor')).to eql 'vendors.name'
    end

    it 'builds a table.column name with given tablename' do
      @dummy.instance_variable_set('@assocs', {vendor: {name: nil}})
      expect(@dummy.build_column_name('vendor:name')).to eql 'vendors.name'
      expect(@dummy.build_column_name('vendor.name')).to eql 'vendors.name'
    end
  end
end