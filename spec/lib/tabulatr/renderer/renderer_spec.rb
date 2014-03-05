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

  describe "#build_static_table" do
    it 'sets main_klass of Renderer' do
      klass = Product
      view = double(render: nil)
      fake_block = Proc.new { }
      renderer = Tabulatr::Renderer.new(klass, view)
      expect{renderer.build_static_table([], &fake_block)}.to(
        change{Tabulatr::Renderer.main_klass}.from(nil).to(Product)
      )
    end
  end

end
