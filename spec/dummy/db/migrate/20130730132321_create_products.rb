class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.references :vendor, index: true
      t.string :title
      t.decimal :price
      t.boolean :active

      t.timestamps
    end
  end
end
