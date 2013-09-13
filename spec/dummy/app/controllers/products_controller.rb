class ProductsController < ApplicationController

  def simple_index
    tabulatr_for Product
  end

  def one_item_per_page_with_pagination
    @pagination = true
    tabulatr_for Product, {action: 'one_item_per_page'}
  end

  def one_item_per_page_without_pagination
    @pagination = false
    tabulatr_for Product, {action: 'one_item_per_page'}
  end

  def count_tags
    tabulatr_for Product
  end

  def stupid_array
    @products = Product.order('price asc').limit(11).to_a
  end
end
