require 'spec_helper'

describe Tabulatr::Renderer::Checkbox do

  describe "#human_name" do

    it "generates a checkbox" do
      checkbox = Tabulatr::Renderer::Checkbox.new
      expect(checkbox.human_name).to eq('<input class="tabulatr_mark_all" id="mark_all" name="mark_all" type="checkbox" value="1" />')
    end

  end

end
