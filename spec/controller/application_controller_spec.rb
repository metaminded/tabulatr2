require 'rails_helper'

# RSpec.configure do |c|
#   c.infer_base_class_for_anonymous_controllers = false
# end

describe ApplicationController, type: :controller do
  controller do
    def index
      tabulatr_for Product
    end

    def current_user
      "Han Solo"
    end
  end

  describe "passing locales to Tabulatr::Data" do
    it "implicitly creates a current_user local if not already present" do
      request.accept = "application/json"
      Product.create!(:title => 'bar', :active => true, :price => 10.0)
      fake_response = double({foo: 'bar'})

      expect_any_instance_of(Tabulatr::Data).to receive(:data_for_table).with(
        {"pagesize"=>"20", "arguments"=>"products:title", "controller"=>"anonymous", "action"=>"index"},
        {:locals=>{current_user: "Han Solo"}, controller: controller}
      ).and_return(fake_response)
      expect(fake_response).to receive(:to_tabulatr_json).and_return({})

      get :index, pagesize: 20, arguments: 'products:title'
      expect(response.code).to eq '200'
    end
  end
end
