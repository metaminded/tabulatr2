class ProductsController < ApplicationController

  def show
  end

  def simple_index
    tabulatr_for Product
  end

  def one_item_per_page_with_pagination
    @pagination = true
    tabulatr_for Product, render_action: 'one_item_per_page'
  end

  def one_item_per_page_without_pagination
    @pagination = false
    tabulatr_for Product, render_action: 'one_item_per_page'
  end

  def count_tags
    tabulatr_for Product
  end

  def stupid_array
    @products = Product.order('price asc').limit(11).to_a
  end

  def with_batch_actions
    begin
      tabulatr_for Product, render_action: 'with_batch_actions' do |batch_actions|
        batch_actions.destroy do |ids|
          ids.each do |id|
            Product.find(id).destroy
          end
        end
      end
    rescue Exception => e
      puts e.backtrace
      raise e
    end
  end

  def with_styling
    tabulatr_for Product
  end

  def implicit_columns
    tabulatr_for Product
  end

  def local_storage
    begin
      tabulatr_for Product
    rescue Exception => e
      puts e.backtrace
      raise e
    end
  end

  def without_filters
    tabulatr_for Product
  end

  def two_tables
  end
end
