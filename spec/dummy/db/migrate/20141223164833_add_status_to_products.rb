class AddStatusToProducts < ActiveRecord::Migration
  def change
    add_column :products, :status, :integer, default: 0
  end
end
