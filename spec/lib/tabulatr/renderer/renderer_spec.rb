require 'spec_helper'

describe Tabulatr::Renderer do

  describe "#generate_id" do

    it "generates a 'unique' id for a table" do
      klass = Product
      renderer = Tabulatr::Renderer.new(klass, nil)
      first_id = renderer.generate_id
      second_id = renderer.generate_id
      expect(first_id).to_not eq second_id
    end
  end

  describe '.initialize' do
    it 'sets pagination_position to top if not set explicitely' do
      renderer = Tabulatr::Renderer.new(Product, nil)
      expect(renderer.instance_variable_get('@table_options')[:pagination_position]).to eq :top
    end
  end
end
