require 'spec_helper'

describe Tabulatr::JsonBuilder do

  describe '.insert_attribute_in_hash' do
    it "does not complain when no id is manually provided" do
      attribute = {action: :id}
      data = {title: 'test', price: '7.0 EUR'}
      expect{Tabulatr::JsonBuilder.insert_attribute_in_hash(attribute, data)}.to_not raise_error
    end

    it "complains when a non given attribute other than id is requested" do
      attribute = {action: :bar}
      data = {title: 'test', price: '7.0 EUR'}
      expect{Tabulatr::JsonBuilder.insert_attribute_in_hash(attribute, data)}.to raise_error
    end

    # it 'accepts arguments without table name' do
    #   attribute = {action: :title}
    #   data = {"products"=>
    #     {"title"=>"title 9", "id"=>10, "price"=>"32.0 EUR",
    #       "vendor_product_name"=>"title 9 from my first vendor"},
    #   "vendor"=>
    #     {"name"=>"my first vendor"},
    #   "tags"=>{"title"=>"''", "count"=>0},
    #   "_row_config"=>{"class"=>"tabulatr-row"}, "id"=>10}
    #   expect{Tabulatr::JsonBuilder.insert_attribute_in_hash(attribute, data)}.to_not raise_error
    # end
  end
end
