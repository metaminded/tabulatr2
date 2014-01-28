class AddPublishAtToProducts < ActiveRecord::Migration
  def change
    add_column :products, :publish_at, :datetime
  end
end
