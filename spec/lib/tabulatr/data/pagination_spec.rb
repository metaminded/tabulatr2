require 'rails_helper'

describe Tabulatr::Data::Pagination do
  class DummyPaginationClass
    include Tabulatr::Data::Pagination
  end

  before(:all) do
    @dummy = DummyPaginationClass.new
  end
  describe '.compute_pagination' do
    it "computes an offset" do
      count = double(count: 20)
      @dummy.instance_variable_set('@relation', count)
      pagination = @dummy.compute_pagination(1, 10)
      expect(pagination[:offset]).to be 0
      pagination = @dummy.compute_pagination(2, 10)
      expect(pagination[:offset]).to be 10
      pagination = @dummy.compute_pagination(3, 10)
      expect(pagination[:offset]).to be 20
      pagination = @dummy.compute_pagination(4, 10)
      expect(pagination[:offset]).to be 30
    end
  end
end
