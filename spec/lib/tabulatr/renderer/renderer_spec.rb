require 'spec_helper'

describe Tabulatr::Renderer do

  describe "#generate_id"

  it "generates a 'unique' id for a table" do
    klass = Product
    renderer = Tabulatr::Renderer.new(klass, nil)
    first_id = renderer.generate_id
    second_id = renderer.generate_id
    expect(first_id).to_not eq second_id
  end

end
