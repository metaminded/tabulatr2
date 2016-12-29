class VendorsController < ApplicationController
  attr_reader :split

  def index
     @split = params[:split] && params[:split].to_f || 100
     tabulatr_for Vendor
  end
end
