require 'spec_helper'

describe Tabulatr::Data::Sorting do
  class DummySpecClass
    include Tabulatr::Data::Sorting
    include Tabulatr::Data::ColumnNameBuilder
  end

  before(:each) do
    @dummy = DummySpecClass.new
    @dummy.instance_variable_set('@relation', Product.all)
    @dummy.instance_variable_set('@table_name', 'products')
    @dummy.instance_variable_set('@base', Product)
  end

  describe '.apply_sorting' do

    context 'no sortparam' do

      context 'with default order given' do
        it 'uses the given order' do
          @dummy.apply_sorting(nil, 'products.title desc')
          expect(@dummy.instance_variable_get('@relation').to_sql)
            .to match /ORDER BY products.title desc/
        end
      end

      context 'with no default order given' do
        it 'sorts by primary_key descending' do
          @dummy.apply_sorting(nil)
          expect(@dummy.instance_variable_get('@relation').to_sql)
            .to match /ORDER BY products.id desc/
        end
      end
    end

    context 'sortparam given' do
      context 'sort by column of main table' do
        context 'sort by "title"' do
          it 'uses the given sortparam' do
            @dummy.instance_variable_set('@columns', {title: {sort_sql: nil}})
            @dummy.apply_sorting('title desc', 'products.id desc')
            expect(@dummy.instance_variable_get('@relation').to_sql)
              .to match /ORDER BY products.title desc/
          end
        end

        context 'sort by "Product.title"' do
          it 'uses the given sortparam' do
            @dummy.instance_variable_set('@cname', 'Product')
            @dummy.instance_variable_set('@columns', {title: {sort_sql: nil}})
            @dummy.apply_sorting('Product.title desc', 'products.id desc')
            expect(@dummy.instance_variable_get('@relation').to_sql)
              .to match /ORDER BY products.title desc/
          end
        end
      end

      context 'sort by association column' do
        it 'sorts by vendor.name' do
          @dummy.instance_variable_set('@includes', [])
          @dummy.instance_variable_set('@assocs', {vendor: {name: {sort_sql: nil}}})
          @dummy.apply_sorting('vendor:name desc')
          expect(@dummy.instance_variable_get('@relation').to_sql)
            .to match /ORDER BY vendors.name desc/
        end
      end

      context 'sort by custom sql' do
        it "sorts by products.title || '' || vendors.name" do
          @dummy.instance_variable_set('@includes', [])
          @dummy.instance_variable_set('@columns',
            {custom_column: {sort_sql: "products.title || '' || vendors.name"}})
          @dummy.apply_sorting('custom_column asc')
          expect(@dummy.instance_variable_get('@relation').to_sql)
            .to match /ORDER BY products.title \|\| '' \|\| vendors.name asc/
        end
      end
    end
  end
end
