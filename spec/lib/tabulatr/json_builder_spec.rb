require 'spec_helper'

describe Tabulatr::JsonBuilder do

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
end
