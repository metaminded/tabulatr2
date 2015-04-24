require 'rails_helper'

describe Tabulatr::Data::Filtering do
  class DummyFilteringClass
    include Tabulatr::Data::Filtering

    def table_columns; []; end
    def filters; []; end
  end

  describe '.apply_date_condition' do
    before(:each) do
      @dummy = DummyFilteringClass.new
      @dummy.instance_variable_set('@relation', Product.all)
      @yesterday = Product.create!(publish_at: DateTime.new(2013, 12, 31, 0, 0))
      @today = Product.create!(publish_at: DateTime.new(2014, 1, 1, 15, 0))
      @week_one = Product.create!(publish_at: DateTime.new(2013, 12, 30, 0, 0))
      @week_two = Product.create!(publish_at: DateTime.new(2014, 1, 5, 8, 0))
      @last_seven_days = Product.create!(publish_at: DateTime.new(2013, 12, 26, 0, 0))
      @last_thirty_days = Product.create!(publish_at: DateTime.new(2013, 12, 3, 0, 0))
      @outside_last_thirty_days = Product.create!(publish_at: DateTime.new(2013, 12, 2, 23, 59))
      @this_month = Product.create!(publish_at: DateTime.new(2014, 1, 15, 0, 0))
      @next_year = Product.create!(publish_at: DateTime.new(2015, 1, 1, 12, 0))
      allow(Date).to receive(:today).and_return(Date.new(2014,1,1))
    end


    it "filters for 'today'" do
      fake_obj = double(filter_sql: 'publish_at')
      @dummy.apply_date_condition(fake_obj, {simple: 'today'})
      result = @dummy.instance_variable_get('@relation')
      expect(result.count).to be 1
      expect(result[0].id).to be @today.id
    end

    it "filters for 'yesterday'" do
      fake_obj = double(filter_sql: 'publish_at')
      @dummy.apply_date_condition(fake_obj, {simple: 'yesterday'})
      result = @dummy.instance_variable_get('@relation')
      expect(result.count).to be 1
      expect(result[0].id).to be @yesterday.id
    end

    it "filters for 'this week'" do
      fake_obj = double(filter_sql: 'publish_at')
      @dummy.apply_date_condition(fake_obj, {simple: 'this_week'})
      result = @dummy.instance_variable_get('@relation')
      expect(result.count).to be 4
      expect(result.map(&:id).sort).to eq [@yesterday.id, @today.id, @week_one.id, @week_two.id].sort
    end

    it "filters for 'last 7 days'" do
      fake_obj = double(filter_sql: 'publish_at')
      @dummy.apply_date_condition(fake_obj, {simple: 'last_7_days'})
      result = @dummy.instance_variable_get('@relation')
      expect(result.map(&:id).sort).to eq ([@last_seven_days.id, @yesterday.id, @today.id, @week_one.id].sort)
    end

    it "filters for 'this month'" do
      fake_obj = double(filter_sql: 'publish_at')
      @dummy.apply_date_condition(fake_obj, {simple: 'this_month'})
      result = @dummy.instance_variable_get('@relation')
      expect(result.map(&:id).sort).to eq ([@today.id, @week_two.id, @this_month.id])
    end

    it "filters for 'last 30 days'" do
      fake_obj = double(filter_sql: 'publish_at')
      @dummy.apply_date_condition(fake_obj, {simple: 'last_30_days'})
      result = @dummy.instance_variable_get('@relation')
      expect(result.map(&:id).sort).to eq ([
        @last_thirty_days.id, @yesterday.id, @last_seven_days.id, @today.id,
        @week_one.id].sort)
    end

    it "filters from 'start_date' to 'end_date'" do
      fake_obj = double(filter_sql: 'publish_at')
      @dummy.apply_date_condition(fake_obj, {
        simple: 'from_to', from: '31.12.2013 15:00',
        to: '15.01.2014 00:00'})
      result = @dummy.instance_variable_get('@relation')
      expect(result.map(&:id)).to eq ([@yesterday.id, @today.id, @week_two.id].sort)
    end
  end

  describe '.apply_search' do

    before(:each) do
      @dummy = DummyFilteringClass.new
      @dummy.instance_variable_set('@relation', Product.all)
    end

    it 'allows to alter the ActiveRecord::Relation' do
      @dummy.instance_variable_set('@search',
        ->(query, relation){ relation.joins(:vendor).where(%{vendors.name LIKE '%#{query}%'})})
      expect{@dummy.apply_search('awesome vendor')}.to_not raise_error
      sql =  @dummy.instance_variable_get('@relation').to_sql
      expect(sql).to match(/INNER JOIN \"vendors\" ON \"vendors\".\"id\" = \"products\".\"vendor_id\"/)
    end

    it 'allows to provide only one argument' do
      @dummy.instance_variable_set('@search', ->(query){ nil })
      expect{@dummy.apply_search('awesome product')}.to_not raise_error
    end

    it 'allows to return a Hash' do
      @dummy.instance_variable_set('@search', ->(query){ {title: query} })
      expect{@dummy.apply_search('awesome product')}.to_not raise_error
      sql =  @dummy.instance_variable_get('@relation').to_sql
      expect(sql).to match(/WHERE \"products\".\"title\"/)
    end

    it 'allows to return an Array' do
      @dummy.instance_variable_set('@search', ->(query){["title = ?", query]})
      expect{@dummy.apply_search('awesome product')}.to_not raise_error
      sql =  @dummy.instance_variable_get('@relation').to_sql
      expect(sql).to match(/WHERE \(title = 'awesome product'\)/)
    end

    it 'can not be called without a block variable' do
      @dummy.instance_variable_set('@search', ->{'hi'})
      expect{@dummy.apply_search('test')}.to raise_error
    end
  end

  describe '.apply_filters' do
    before(:each) do
      @dummy = DummyFilteringClass.new
      @dummy.instance_variable_set('@relation', Product.all)
    end

    it 'applies given filters to the relation' do
      bl = ->(relation, value){ relation.where(price: value) }
      allow(@dummy).to receive(:filters).and_return([Tabulatr::Renderer::Filter.new(:custom_filter, &bl)])
      matched_product = Product.create(price: 10)
      unmatched_product = Product.create(price: 11)
      expect{@dummy.apply_filters({'custom_filter' => '10'})}.to_not raise_error
      result = @dummy.instance_variable_get('@relation')
      expect(result).to match_array([matched_product])
    end

    it 'only searches for a filter if there is no column with that name' do
      fake_column = double(table_name: :custom, name: nil)
      allow(@dummy).to receive(:table_columns).and_return([fake_column])
      allow(@dummy).to receive(:filters).and_return([Tabulatr::Renderer::Filter.new(:custom)])
      expect(@dummy).to receive(:apply_condition).with(fake_column, '10')
      @dummy.apply_filters({'custom' => '10'})
    end
  end
end
