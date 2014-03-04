require 'spec_helper'

describe Tabulatr::Data::Filtering do
  class DummySpecClass
    include Tabulatr::Data::Filtering
  end

  before(:each) do
    @dummy = DummySpecClass.new
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
    Date.stub(:today).and_return(Date.new(2014,1,1))
  end
  describe '.apply_date_condition' do
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
end
