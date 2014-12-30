require 'rails_helper'

describe Tabulatr::Renderer::Checkbox do

  describe "#human_name" do

    it "generates a checkbox" do
      checkbox = Tabulatr::Renderer::Checkbox.new
      expect(checkbox.human_name).to match(/\A<input.+\/>\z/)
      expect(checkbox.human_name).to match(/class="tabulatr_mark_all"/)
      expect(checkbox.human_name).to match(/type="checkbox"/)
    end

  end

end
